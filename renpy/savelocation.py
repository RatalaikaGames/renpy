# Copyright 2004-2019 Tom Rothamel <pytom@bishoujo.us>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# This contains code for different save locations. A save location is a place
# where we store save data, and can retrieve it from.
#
# The current save location is stored in the location variable in loadsave.py.

from __future__ import print_function

import os
import zipfile
import json

import renpy.display
import threading

from renpy.loadsave import clear_slot
import shutil

disk_lock = threading.RLock()

# A suffix used to disambguate temporary files being written by multiple
# processes.
import time
tmp = "." + str(int(time.time())) + ".tmp"


class FileLocation(object):
    """
    A location that saves files to a directory on disk.
    """

    def __init__(self, directory):
        self.directory = directory

        self.active = True

        # A map from slotname to the mtime of that slot.
        self.mtimes = { }

        # The persistent file.
        self.persistent = os.path.join(self.directory, "persistent")

        # The mtime of the persistent file.
        self.persistent_mtime = 0

        # The data loaded from the persistent file.
        self.persistent_data = None
        
    def filename(self, slotname):
        """
        Given a slot name, returns a filename.
        """

        return os.path.join(self.directory, renpy.exports.fsencode(slotname + renpy.savegame_suffix))

    def scan(self):
        """
        Scan for files that are added or removed.
        """

        if not self.active:
            return

        with disk_lock:

            old_mtimes = self.mtimes
            new_mtimes = { }

            suffix = renpy.savegame_suffix
            suffix_len = len(suffix)

            for fn in os.listdir(self.directory):
                if not fn.endswith(suffix):
                    continue

                slotname = fn[:-suffix_len]

                try:
                    new_mtimes[slotname] = os.path.getmtime(os.path.join(self.directory, fn))
                except:
                    pass

            self.mtimes = new_mtimes

            for slotname, mtime in new_mtimes.iteritems():
                if old_mtimes.get(slotname, None) != mtime:
                    clear_slot(slotname)

            for slotname in old_mtimes:
                if slotname not in new_mtimes:
                    clear_slot(slotname)

            if os.path.exists(self.persistent):
                mtime = os.path.getmtime(self.persistent)

                if mtime != self.persistent_mtime:
                    data = renpy.persistent.load(self.persistent)
                    if data is not None:
                        self.persistent_mtime = mtime
                        self.persistent_data = data

    def save(self, slotname, record):
        """
        Saves the save record in slotname.
        """

        filename = self.filename(slotname)

        with disk_lock:
            record.write_file(filename)

        self.scan()

    def list(self):
        """
        Returns a list of all slots with savefiles in them, in arbitrary
        order.
        """

        return list(self.mtimes)

    def mtime(self, slotname):
        """
        For a slot, returns the time the object was saved in that
        slot.

        Returns None if the slot is empty.
        """

        return self.mtimes.get(slotname, None)

    def json(self, slotname):
        """
        Returns the JSON data for slotname.

        Returns None if the slot is empty.
        """

        with disk_lock:

            try:
                filename = self.filename(slotname)
                zf = zipfile.ZipFile(filename, "r")
            except:
                return None

            try:

                try:
                    data = zf.read("json")
                    data = json.loads(data)
                    return data
                except:
                    pass

                try:
                    extra_info = zf.read("extra_info").decode("utf-8")
                    return { "_save_name" : extra_info }
                except:
                    pass

                return { }

            finally:
                zf.close()

    def screenshot(self, slotname):
        """
        Returns a displayable that show the screenshot for this slot.

        Returns None if the slot is empty.
        """

        with disk_lock:

            mtime = self.mtime(slotname)

            if mtime is None:
                return None

            try:
                filename = self.filename(slotname)
                zf = zipfile.ZipFile(filename, "r")
            except:
                return None

            try:
                png = False
                zf.getinfo('screenshot.tga')
            except:
                png = True
                zf.getinfo('screenshot.png')

            zf.close()

            if png:
                screenshot = renpy.display.im.ZipFileImage(filename, "screenshot.png", mtime)
            else:
                screenshot = renpy.display.im.ZipFileImage(filename, "screenshot.tga", mtime)

            return screenshot

    def load(self, slotname):
        """
        Returns the log component of the file found in `slotname`, so it
        can be loaded.
        """

        with disk_lock:

            filename = self.filename(slotname)

            zf = zipfile.ZipFile(filename, "r")
            rv = zf.read("log")
            zf.close()

            return rv

    def unlink(self, slotname):
        """
        Deletes the file in slotname.
        """

        with disk_lock:

            filename = self.filename(slotname)
            if os.path.exists(filename):
                os.unlink(filename)

            self.scan()

    def rename(self, old, new):
        """
        If old exists, renames it to new.
        """

        with disk_lock:

            old = self.filename(old)
            new = self.filename(new)

            if not os.path.exists(old):
                return

            if os.path.exists(new):
                os.unlink(new)

            os.rename(old, new)

            self.scan()

    def copy(self, old, new):
        """
        Copies `old` to `new`, if `old` exists.
        """

        with disk_lock:
            old = self.filename(old)
            new = self.filename(new)

            if not os.path.exists(old):
                return

            shutil.copyfile(old, new)

            self.scan()

    def load_persistent(self):
        """
        Returns a list of (mtime, persistent) tuples loaded from the
        persistent file. This should return quickly, with the actual
        load occuring in the scan thread.
        """

        if self.persistent_data:
            return [ (self.persistent_mtime, self.persistent_data) ]
        else:
            return [ ]

    def save_persistent(self, data):
        """
        Saves `data` as the persistent data. Data is a binary string giving
        the persistent data in python format.
        """

        with disk_lock:

            if not self.active:
                return

            with open(self.persistent, "wb") as f:
                f.write(data)

    def __eq__(self, other):
        if not isinstance(other, FileLocation):
            return False

        return self.directory == other.directory

def quit():  # @ReservedAssignment
    pass

def init():
    location = FileLocation(renpy.config.savedir)

    # Scan the location once.
    location.scan()

    renpy.loadsave.location = location
