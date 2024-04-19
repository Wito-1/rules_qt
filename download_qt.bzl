"""
Downloads QT using aqtinstall - Another Qt CLI Installer

https://github.com/miurahr/aqtinstall

Requires python to be installed.
"""

# The qt_modules.bzl file is auto-generated based on the qt_modules() def in
# the root BUILD.bazel file.
load("//:qt_modules.bzl", "QT_MODULES")
load("@bazel_skylib//lib:paths.bzl", "paths")

_PATHS = {
  "mac": "macos",
  "linux": "gcc_64",
  "win64_mingw": "mingw_64",
}

def _download_qt_impl(rctx):
    archiver_7z = rctx.download_and_extract(
        url = rctx.attr.url_7z,
        sha256 = rctx.attr.sha256_7z,
        output = "archiver_7z",
    )

    archiver_bin = rctx.path("archiver_7z/7zz")
    
    # We have to write our own download_and_extract() because the one in ctx
    # doesn't support 7z decompress & that's what qt modules are downloaded as.
    for qt_module, download_info in QT_MODULES.items():
        res = rctx.download(
            url = download_info["url"],
            sha256 = download_info["sha256"],
            output = "archives/{}".format(paths.basename(download_info["url"]))
        )
        if not res.success:
            fail("Failed to download:\n{}\n{}".format(download_info["url"], res.stderr))

        archive = paths.basename(download_info["url"])
        arguments = [archiver_bin.realpath, "x"]
        arguments += ["archives/{}".format(archive), "-o{}".format(".")]
        res = rctx.execute(arguments)
        if res.return_code != 0:
            fail("Failed to decompress archive:\n{}\n{}".format(" ".join([str(arg) for arg in arguments]), res.stderr))


    path_lookup = rctx.attr.os
    if rctx.attr.os == "windows":
        path_lookup = rctx.attr.windows_architecture

    # The downloaded files end up under 6.4.0/gcc_64 for linux, but the second
    # directory is different per OS. Symlink the relevant directory 
    # for usage in this repository.
    base_path = "{}/{}".format(rctx.attr.version, _PATHS[path_lookup])
    for entry in rctx.path(base_path).readdir():
        rctx.symlink(entry, entry.basename)

    # Write out bazel workspace files
    rctx.file("WORKSPACE", content = "")
    rctx.file("MODULE.bazel", content = "module(name = {})".format(rctx.attr.name))

    # Write the qt_libraries definition file. 
    qt_library_defs = rctx.read(rctx.attr._qt_libraries)
    rctx.file(rctx.attr._qt_libraries.name, content = qt_library_defs)

    # Write the toplevel BUILD.bazel file, removing the @rules_qt since the libraries def is contained therein
    build_file_contents = rctx.read(rctx.attr.build_file)
    rctx.file("BUILD.bazel", content = build_file_contents.replace("@rules_qt", ""))

download_qt = repository_rule(
    implementation=_download_qt_impl,
    attrs={
        "version": attr.string(default = "6.4.0"),
        "os": attr.string(default = "linux"), 
        "target_sdk": attr.string(default = "desktop"),
        "windows_architecture": attr.string(default = ""),
        "build_file": attr.label(default = "@rules_qt//:qt_linux_x86_64.BUILD"),
        "url_7z": attr.string(default = "https://github.com/ip7z/7zip/releases/download/23.01/7z2301-linux-x86.tar.xz"),
        "sha256_7z": attr.string(default = "a4cd3dba5dcb22d0543156258f77011a838a5402563011c2aca11c3562687857"),
        "_qt_libraries": attr.label(default = "@rules_qt//:qt_libraries.bzl"),
    }
)
