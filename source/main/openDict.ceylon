
import ceylon.file {
    File,
    parsePath,
    Directory
}

"Run the module `openDict`."


shared void openDict(String dictPath) {

    value resource_ = parsePath(dictPath).resource;

    if (is Directory resource_) {

        for (path in resource_.childPaths()) {
            String currentFilePhath = path.string;
            value pathOfF = parsePath(currentFilePhath).resource;
            if (is File pathOfF) { //Check if is a file
                if(checkSuffix(pathOfF.name)) { //Check if is a VM file
                    readFile(currentFilePhath);
                }
            }
        }

    }
}

shared Boolean checkSuffix(String str){
    value index =str.indexOf(".");
    String ext = str.substring(index);
    return ext.equals(".vm");
}
