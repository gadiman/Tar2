
import ceylon.file {
    File,
    parsePath,
    Directory,
    Resource,
    forEachLine,
    createFileIfNil,
    Nil
}

"Run the module `openDict`."


shared void openDict(String dictPath) {

    value resource_ = parsePath(dictPath).resource;
    variable String tmp = "";


    if (is Directory resource_) {

        Integer numOfVmFiles= resource_.childPaths("*.vm").size;
        variable String dict = resource_.string;

        for (path in resource_.childPaths("*.vm")) {
            String currentFilePhath = path.string;
            value pathOfF = parsePath(currentFilePhath).resource;

            if (is File pathOfF) { //Check if is a file
                if (numOfVmFiles == 1) {//only one vm file
                    readFile(currentFilePhath);
                }
                else {//serch for Sys.vm file

                    if (pathOfF.name.equals("Sys.vm")) {
                        tmp = textOfFile(pathOfF.string).plus(tmp);
                    } else {
                        tmp +=textOfFile(pathOfF.string);
                    }
                }
            }

        }
        if (numOfVmFiles > 1) {
            String newPath = dict + "\\result.gadAndShimon";
            Resource newPath_ = parsePath(newPath).resource;
            if (is File|Nil newPath_) {
                File file = createFileIfNil(newPath_);
                try (appender = file.Appender()) {//Appender no remove the exists text
                    appender.write(tmp);
                }
            }
            readFile(newPath_.string);
        }
    }
}


String textOfFile(String path){
    variable String tmp="";
    Resource resource = parsePath(path).resource;
    if (is File resource) {
    forEachLine(resource, (String line) {
        tmp += line+"\n";
     });
    }

    return tmp +"\n";
}

