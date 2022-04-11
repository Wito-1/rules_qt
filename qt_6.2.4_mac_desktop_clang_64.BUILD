load("@//:qt_libraries.bzl", "QT_LIBRARIES")

[
    cc_library(
        name = "qt_%s_mac" % name,
        hdrs = glob(["include/%s/**" % include_folder]),  #glob(["%s/**" % include_folder], allow_empty = True),
        includes = [
            "include",
            "include/QtCore",
        ],
        linkopts = ["-F/usr/local/opt/qt@6/lib"] + [
            "-framework %s" % library_name.replace("6", "") # macOS qt libs do not contain a 6 - e.g. instead of Qt6Core the lib is called QtCore
        ],
        target_compatible_with = ["@platforms//os:osx"],
        visibility = ["//visibility:public"],
    )
    for name, include_folder, library_name, _ in QT_LIBRARIES
]

filegroup(
    name = "uic",
    srcs = ["libexec/uic"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "moc",
    srcs = ["libexec/moc"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "plugin_files",
    srcs = glob(["share/qt/plugins/**/*"]),
    visibility = ["//visibility:public"],
)