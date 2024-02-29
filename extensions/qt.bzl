load("//:download_qt.bzl", "download_qt")

def _aqt_install_impl(mctx):
    for mod in mctx.modules:
        for arg in mod.tags.install:
            if arg.type == "windows" and not "windows_architecture":
                fail("When using windows as a download type, you need to provide a windows architecture to use")

            download_qt(
                name = arg.name,
                version = arg.version,
                os = arg.os,
                type = arg.type,
                build_file = arg.build_file,
                windows_architecture = arg.windows_architecture,
	        qt_modules = arg.qt_modules,
            )

_install = tag_class(
    attrs = {
        "name": attr.string(default = "qt"),
        "version": attr.string(default = "6.4.0"),
        "os": attr.string(default = "linux"), #TODO Make this cross with at least arm64/mac
        "type": attr.string(default = "desktop"),
        "build_file": attr.label(default = "@rules_qt//:qt_linux_x86_64.BUILD"),
        "windows_architecture": attr.string(default = ""),
	"qt_modules": attr.string_list(default = []),
    },
)

_tag_classes = {
    "install": _install,
}

aqt_install = module_extension(
    implementation = _aqt_install_impl,
    tag_classes = _tag_classes,
)
