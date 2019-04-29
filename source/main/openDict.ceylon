
import ceylon.file {
    File,
    parsePath,
    Directory,
    Resource,
    forEachLine,
    createFileIfNil,
    Nil
}
import ceylon.collection { ArrayList }
import java.util.concurrent { Semaphore }
import java.lang { Thread, Math }


"Run the module `openDict`."


shared void openDict(String dictPath) {

    value resource_ = parsePath(dictPath).resource;

    variable String tmp = "";//for text of vm's files


    if (is Directory resource_) {

        Integer numOfVmFiles= resource_.childPaths("*.vm").size;//num of VM's files on directory
        variable String dict = resource_.string;//neme of directory

        for (path in resource_.childPaths("*.vm")) {
            String currentFilePhath = path.string;
            value pathOfF = parsePath(currentFilePhath).resource;

            if (is File pathOfF) { //Check if is a file
                if (numOfVmFiles == 1) {//only one vm file
                    readFile(currentFilePhath);
                }
                else {//serch for Sys.vm file and put him at the first of the result file

                    if (pathOfF.name.equals("Sys.vm")) {
                        tmp = textOfFile(pathOfF.string).plus(tmp);//put Sys.vm text on the head
                    } else {
                        tmp +=textOfFile(pathOfF.string);
                    }
                }
            }

        }
        if (numOfVmFiles > 1) { //output one asm file for each directory
            String newPath = dict + "\\"+resource_.name+".gadAndShimon";
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

//this function reading the Vm's files and return the text as a  String
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

