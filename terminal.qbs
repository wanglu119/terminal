import qbs 1.0

Project {
    name: "Terminal"

    readonly property string version: "0.1.0"

    minimumQbsVersion: "1.6"

    qbsSearchPaths: ["qbs/shared", "qbs/local"]

    references: [
        "app/app.qbs",
        "data/data.qbs",
        "imports/terminal/terminal.qbs",
        "lib/lib.qbs",
    ]
}