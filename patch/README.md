README.md
=========
MTK wants SELinux updates in the form of a patch file against Apollo.  They describe the procedure in "Vizio ODM Patch Rule v0.1.pdf", which is in Confluence at <https://vizio-sc.atlassian.net/wiki/download/attachments/828309980/Vizio%20ODM%20Patch%20Rule%20v0.1.pdf?api=v2>.

``patchit.sh`` generates a patch in the form that MTK has requested.  It extracts the SELinux source files from an Apollo tarball into ``./old/``.  Then it copies SELinux files from this repo into ``./new/``.  Finally, it generates a patch file by ``diff``'ing ``./old/`` and ``./new/``.

Two output files are generated:

     * <Apollo SDK name>.patch .. Patch file
     * <Apollo SDK name>.tgz .... Tarball with new or modified files

Usage: ``patchit.sh SDK_tarball [--skip-untar]``

In general, ``patchit.sh`` will refuse to overwrite pre-existing ``./old/`` and ``./new/`` directories.

Since extracting files from the Apollo tarball can take up to 10 minutes, you can use ``--skip-untar`` if the files have already been extracted.  You don't have to delete ``./old/`` in this case.
