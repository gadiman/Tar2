import ceylon.file {
    forEachLine,
    Resource,
    File,
    parsePath,
    lines,
    Directory,
    Visitor,
    home
}

shared String readFile(String filePath,Boolean firstFile, Boolean lastFile,String nameOfF,String pText) {
    Resource resource = parsePath(filePath).resource;
    // Resource has 4 subtypes: File | Directory | Link | Nil
    // We have to resolve the type.
    variable String textOfFile="";
    if(firstFile && !lastFile){
        textOfFile+= init();
    }

    if(pText != ""){
        textOfFile+=pText;
    }

    if (is File resource) {
        variable String dict = resource.directory.string;
        value index =resource.name.indexOf(".");
        variable String nameOfFile = resource.name.substring(0,index);
        forEachLine(resource, (String line) {

            {String*} firstWords = line.split();
            String? firstWord = firstWords.first;

            switch (firstWord)
            case ("add") {
                textOfFile += addFun();
            }
            case ("sub") {
                textOfFile += subFun();
            }
            case ("neg") {
                textOfFile += negFun();
            }
            case ("and") {
                textOfFile += andFun();
            }
            case ("not") {
                textOfFile += notFun();
            }
            case ("or") {
                textOfFile += orFun();
            }
            case ("eq") {
                textOfFile += eqFun();
            }
            case ("lt") {
                textOfFile += ltFun();
            }
            case ("gt") {
                textOfFile += gtFun();
            }
            case ("pop") {
                textOfFile += popFun(line,nameOfFile);
            }
            case ("push") {
                textOfFile += pushFun(line,nameOfFile);
            }
            case ("label"){
                textOfFile += labelFun(line,nameOfFile);
            }
            case ("goto")     {
                textOfFile += gotoFun(line,nameOfFile);
                }
            case ("if-goto")  {
                textOfFile += if_gotoFun(line,nameOfFile);
                }
            case ("call")     {
                textOfFile += callFun(line);
              }
            case ("function") {
                textOfFile += functionFun(line);
              }
            case ("return")   {
                textOfFile += returnFun();
               }
            else {  }
        });


        if(!lastFile && !firstFile){
        String pathForAsmFile = changeNameOfSuffix(resource.name,dict);
        writeFileAsm(pathForAsmFile,textOfFile);
        textOfFile ="";
        }
        if(lastFile && !firstFile){
            String pathForAsmFile = dict+"\\"+nameOfF+".asm";
            writeFileAsm(pathForAsmFile,textOfFile);
            textOfFile ="";
            print(pathForAsmFile);
            textOfFile ="";
        }


    }

    return textOfFile;



}

String changeNameOfSuffix(String name,String dict){
    value index =name.indexOf(".");
    variable String newName = name.substring(0,index);
    newName+=".asm";
    return dict+"\\" +newName;
}

//---------------------------------------------Targil 1-----------------------------------------------//

String addFun(){
    variable String tmp="";
    tmp+="@SP\n"; //set A ="SP"
    tmp+="A=M\n"; //A=RAM[A]=RAM[SP]
    tmp+="A=A-1\n";//the location of the first operand
    tmp+="D=M\n"; //set D= first operand
    tmp+="A=A-1\n";//the location of the second operand
    tmp+="M=M+D\n";//Adding  operands and writing in the stack (on the head)
    tmp+="@SP\n"; //set A ="SP"
    tmp+="M=M-1\n"; //SP value = SP value -1

    return tmp;
}

String subFun(){
    variable String tmp="";
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M\n";//A=RAM[A]=RAM[SP]
    tmp+="A=A-1\n";//the location of the first operand
    tmp+="D=M\n";//set D= firs operand
    tmp+="A=A-1\n";//the location of the second operand
    tmp+="M=M-D\n";//Subtraction operands and writing in the stack (on the head)
    tmp+="@SP\n"; //set A ="SP"
    tmp+="M=M-1\n"; //SP value = SP value -1
    return tmp;
}

String negFun(){
    variable String tmp="";
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M\n";//A=RAM[A]=RAM[SP]
    tmp+="A=A-1\n";///the location of the  operand
    tmp+="D=M\n";//set D=operand
    tmp+="M=-D\n";//writing -operand in the stack (on the head)

    return tmp;
}

String andFun(){
    variable String tmp="";
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M\n";//A=RAM[A]=RAM[SP]
    tmp+="A=A-1\n";//the location of the first operand
    tmp+="D=M\n";//set D=operand
    tmp+="A=A-1\n";//the location of the second operand
    tmp+="M=M&D\n";//writing the result(T/F) in the stack (on the head)
    tmp+="@SP\n"; //set A ="SP"
    tmp+="M=M-1\n"; //SP value = SP value -1
    return tmp;
}

String notFun(){
    variable String tmp="";
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M\n";//A=RAM[A]=RAM[SP]
    tmp+="A=A-1\n";//the location of the operand
    tmp+="D=M\n";//set D=operand
    tmp+="M=!D\n";//writing the result(T/F) in the stack (on the head)

    return tmp;

}

String orFun(){
    variable String tmp="";
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M\n";//A=RAM[A]=RAM[SP]
    tmp+="A=A-1\n";//the location of the first operand
    tmp+="D=M\n";//set D= first operand
    tmp+="A=A-1\n";//the location of the second first operand
    tmp+="M=M|D\n";//writing the result(T/F) in the stack (on the head)
    tmp+="@SP\n"; //set A ="SP"
    tmp+="M=M-1\n"; //SP value = SP value -1

    return tmp;
}


variable Integer counter = 0;//For lables


String eqFun(){
    variable String tmp="";
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M\n";//A=RAM[A]=RAM[SP]
    tmp+="A=A-1\n";//the location of the first operand
    tmp+="D=M\n";//set D= first operand
    tmp+="A=A-1\n";//the location of the second operand
    tmp+="D=M-D\n"; //D=second opreand-firs operand
    tmp+="@IF_TRUE"+counter.string+"\n"; //first lable
    tmp+="D;JEQ\n"; //jump if equals to the labale that located in A
    tmp+="D=0\n"; //If we are here, that means they are not equal (no jumped)  so D=false
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M-1\n";//the location of the first operand -not head of the stack yet
    tmp+="A=A-1\n";//the location of the second operand - now is the head of the stack
    tmp+="M=D\n"; //writing the result F (0) in the stack (on the head)
    tmp+="@IF_FALSE"+counter.string+"\n"; //second lable
    tmp+="0;JMP\n"; //jump to second lable that located in A

    tmp+="(IF_TRUE" + counter.string + ")\n"; //first lable commands
    tmp+="D=-1\n";//set D= -1
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M-1\n";//the location of the first operand -not head of the stack yet
    tmp+="A=A-1\n";//the location of the second operand - now iss the head of the stack
    tmp+="M=D\n";//writing the result T (-1) in the stack (on the head)

    tmp+="(IF_FALSE" + counter.string + ")\n";//Second lable commands
    tmp+="@SP\n";//set A="SP"
    tmp+="M=M-1\n";//SP value = SP value -1

    counter+=1;
    return tmp;
}

String ltFun(){
    variable String tmp="";
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M\n";//A=RAM[A]=RAM[SP]
    tmp+="A=A-1\n";//the location of the first operand
    tmp+="D=M\n";//set D= first operand
    tmp+="A=A-1\n";//the location of the second operand
    tmp+="D=M-D\n"; //D=second opreand-firs operand
    tmp+="@IF_TRUE"+counter.string+"\n"; //first lable
    tmp+="D;JLT\n"; //jump if x<y (comp<0) to the labale that located in A
    tmp+="D=0\n"; //If we are here, that means they are not equal (no jumped)  so D=false
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M-1\n";//the location of the first operand -not head of the stack yet
    tmp+="A=A-1\n";//the location of the second operand - now iss the head of the stack
    tmp+="M=D\n"; //writing the result F (0) in the stack (on the head)
    tmp+="@IF_FALSE"+counter.string+"\n"; //second lable
    tmp+="0;JMP\n"; //jump to second lable that located in A

    tmp+="(IF_TRUE" + counter.string + ")\n"; //first lable commands
    tmp+="D=-1\n";//set D= -1
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M-1\n";//the location of the first operand -not head of the stack yet
    tmp+="A=A-1\n";//the location of the second operand - now is the head of the stack
    tmp+="M=D\n";//writing the result T (-1) in the stack (on the head)

    tmp+="(IF_FALSE" + counter.string + ")\n";//Second lable commands
    tmp+="@SP\n";//set A="SP"
    tmp+="M=M-1\n";//SP value = SP value -1

    counter+=1;
    return tmp;
}

String gtFun(){
    variable String tmp="";
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M\n";//A=RAM[A]=RAM[SP]
    tmp+="A=A-1\n";//the location of the first operand
    tmp+="D=M\n";//set D= first operand
    tmp+="A=A-1\n";//the location of the second operand
    tmp+="D=M-D\n"; //D=second opreand-firs operand
    tmp+="@IF_TRUE"+counter.string+"\n"; //first lable
    tmp+="D;JGT\n"; //jump if x>y (comp >0) to the labale that located in A
    tmp+="D=0\n"; //If we are here, that means they are not equal (no jumped)  so D=false
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M-1\n";//the location of the first operand -not head of the stack yet
    tmp+="A=A-1\n";//the location of the second operand - now iss the head of the stack
    tmp+="M=D\n"; //writing the result F (0) in the stack (on the head)
    tmp+="@IF_FALSE"+counter.string+"\n"; //second lable
    tmp+="0;JMP\n"; //jump to second lable that located in A

    tmp+="(IF_TRUE" + counter.string + ")\n"; //first lable commands
    tmp+="D=-1\n";//set D= -1
    tmp+="@SP\n";//set A ="SP"
    tmp+="A=M-1\n";//the location of the first operand -not head of the stack yet
    tmp+="A=A-1\n";//the location of the second operand - now is the head of the stack
    tmp+="M=D\n";//writing the result T (-1) in the stack (on the head)

    tmp+="(IF_FALSE" + counter.string + ")\n";//Second lable commands
    tmp+="@SP\n";//set A="SP"
    tmp+="M=M-1\n";//SP value = SP value -1

    counter+=1;
    return tmp;

}

String popFun(String line,String nameOfFile){
    {String*} sentence  = line.split();

    String? segment = sentence.rest.first;
    assert (exists segment);//The segment

    String? index = sentence.rest.rest.first;
    assert (exists index); //The number that showing after the segment

    variable String tmp="";

    switch (segment)
    case ("argument") {
        tmp+= "@ARG\n"; //set A="ARG" (name of register)
        tmp+="D=M\n"; //D=M=RAM[A]=RAM[ARG}
        tmp+="@" + index +"\n";//set A = index (pop segment index)
        tmp+="D=D+A\n"; //D = RAM[ARG] + index
        tmp+="@13\n"; //set A=13 (load temp reg to A)
        tmp+="M=D\n"; // write in RAM[13] =  RAM[ARG]+ index
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M-1\n"; // SP value = SP value -1
        tmp+="@SP\n"; //set A = "SP"
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP] the new value of SP
        tmp+="D=M\n"; //the new value of SP
        tmp+="@13\n"; //set A=13 (load temp reg to A)
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[13]
        tmp+="M=D\n"; // write the argument on the stack

    }
    case ("local") {
        tmp+= "@LCL\n"; //set A="ARG" (name of register)
        tmp+="D=M\n"; //D=M=RAM[A]=RAM[ARG}
        tmp+="@" + index +"\n";//set A = index (push segment index)
        tmp+="D=D+A\n"; //D=ARG[LCL]+INDEX
        tmp+="@13\n";//A=13
        tmp+="M=D\n"; // M=ARG[LCL]+INDEX
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M-1\n"; // SP value = SP value - 1
        tmp+="@SP\n"; //set A= "SP"
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[13]
        tmp+="D=M\n"; //NEW VALUE OF SP
        tmp+="@13\n";  //A=13
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[13]
        tmp+="M=D\n"; // write the argument on the stack

    }
    case ("static") {

        tmp+="@"+ nameOfFile+ "." +index + "\n";//set A= "name_of_file.index"
        tmp+="D=A\n";//D=name_of_file.index
        tmp+="@13\n";//A=13
        tmp+="M=D\n";// write the  var on the stack
        tmp+="@SP\n";//A=SP
        tmp+="M=M-1\n";//SP VALUE -1
        tmp+="@SP\n";//set A="SP"
        tmp+="A=M\n";//A=RAM[SP]
        tmp+="D=M\n";//D=RAM[RAM[SP]]
        tmp+="@13\n";//A=13
        tmp+="A=M\n";//A=RAM[13]
        tmp+="M=D\n";// write the  var on the stack

    }
    case ("this") {
        tmp+= "@THIS\n"; //set A="ARG" (name of register)
        tmp+="D=M\n"; //D=M=RAM[A]=RAM[ARG}
        tmp+="@" + index +"\n";//set A = index (push segment index)
        tmp+="D=D+A\n";//D=RAM[THIS]+INDEX
        tmp+="@13\n";//A=13
        tmp+="M=D\n"; // write the argument on the stack
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M-1\n"; // SP value = SP value +1
        tmp+="@SP\n"; //set A= "SP"
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP]
        tmp+="D=M\n";//D=RAM[RAM[SP]]
        tmp+="@13\n";//A=13
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n"; // write the argument on the stack

    }
    case ("that") {
        tmp+= "@THAT\n"; //set A="ARG" (name of register)
        tmp+="D=M\n"; //D=M=RAM[A]=RAM[ARG}
        tmp+="@" + index +"\n";//set A = index (push segment index)
        tmp+="D=D+A\n";//D=RAM[THAT]+INDEX
        tmp+="@13\n";//A=13
        tmp+="M=D\n"; // write the argument on the stack
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M-1\n"; // SP value = SP value -1
        tmp+="@SP\n"; //set A= "SP"
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP]
        tmp+="D=M\n";//D=RAM[RAM[SP]]
        tmp+="@13\n";//A=13
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n"; // write the argument on the stack
    }
    case ("pointer") {
        tmp+="@3\n";//set A="3" (name of register)
        tmp+="D=A\n";//set D=3
        tmp+="@" + index + "\n";//set A = index (push segment index)
        tmp+="D=D+A\n";//D=ARG[POINTER]+INDEX
        tmp+="@13\n";//A=13
        tmp+="M=D\n";//M=ARG[POINTER]+INDEX
        tmp+="@SP\n";//A=13
        tmp+="M=M-1\n";//SP-1
        tmp+="@SP\n";//A=SP
        tmp+="A=M\n";//A=M=RAM[A]=RAM[SP]
        tmp+="D=M\n";//D=RAM[RAM[SP]]
        tmp+="@13\n";//A=13
        tmp+="A=M\n";//A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n";// write the var on the stack



    }
    case ("temp") {
        tmp+="@5\n";//set A="5" (name of register)
        tmp+="D=A\n";//set D=5
        tmp+="@" + index + "\n";//set A = index (push segment index)
        tmp+="D=D+A\n";//D=RAM[TEMP]+INDEX
        tmp+="@13\n";//A=13
        tmp+="M=D\n";//M=RAM[TEMP]+INDEX
        tmp+="@SP\n";//A=13
        tmp+="M=M-1\n";//SP-1
        tmp+="@SP\n";//A=SP
        tmp+="A=M\n";//A=M=RAM[A]=RAM[SP]
        tmp+="D=M\n";//D=RAM[RAM[SP]]
        tmp+="@13\n";//A=13
        tmp+="A=M\n";//A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n";// write the var on the stack
    }
    else {}



    return tmp;
}



String pushFun(String line,String nameOfFile ){
    variable String tmp="";
    {String*} sentence = line.split();

    String? segment = sentence.rest.first;
    assert (exists segment);

    String? index = sentence.rest.rest.first;
    assert (exists index);

    switch (segment)
    case ("argument") {
        tmp+= "@ARG\n"; //set A="ARG" (name of register)
        tmp+="D=M\n"; //D=M=RAM[A]=RAM[ARG}
        tmp+="@" + index +"\n";//set A = index (push segment index)
        tmp+= "A=D+A\n"; // the currrent place on the segment
        tmp+="D=M\n"; // set D= value of the argument
        tmp+="@SP\n"; //set A= "SP"
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n"; // write the argument on the stack
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M+1\n"; // SP value = SP value +1
    }
    case ("local") {
        tmp+= "@LCL\n"; //set A="LCL" (name of register)
        tmp+="D=M\n"; //D=M=RAM[A]=RAM[ARG}
        tmp+="@" + index +"\n";//set A = index (push segment index)
        tmp+= "A=D+A\n"; // the currrent place on the segment
        tmp+="D=M\n"; // set D= value of the local var
        tmp+="@SP\n"; //set A= "SP"
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n"; // write the local var on the stack
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M+1\n"; // SP value = SP value +1

    }
    case ("static") {
        tmp+="@" + nameOfFile + "." + index + "\n"; //set A= "name_of_file.index"
        tmp+="D=M\n"; // D=M =RAM[A]= RAM[ame_of_file.index]
        tmp+="@SP\n";//set A="SP"
        tmp+="A=M\n"; //A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n"; // write the  var on the stack
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M+1\n"; // SP value = SP value +1
    }
    case ("constant") {
        tmp+="@" + index +"\n";//set A=index (constant)
        tmp+="D=A\n";//set D= index (constant)
        tmp+="@SP\n"; //set A= "SP";
        tmp+="A=M\n"; //A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n"; // write the  var on the stack
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M+1\n"; // SP value = SP value +1

    }
    case ("this") {
        tmp+= "@THIS\n"; //set A="ARG" (name of register)
        tmp+="D=M\n"; //D=M=RAM[A]=RAM[ARG}
        tmp+="@" + index +"\n";//set A = index (push segment index)
        tmp+= "A=D+A\n"; // the currrent place on the segment
        tmp+="D=M\n"; // set D= value of the var
        tmp+="@SP\n"; //set A= "SP"
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n"; // write the var on the stack
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M+1\n"; // SP value = SP value +1

    }
    case ("that") {
        tmp+= "@THAT\n"; //set A="ARG" (name of register)
        tmp+="D=M\n"; //D=M=RAM[A]=RAM[ARG}
        tmp+="@" + index +"\n";//set A = index (push segment index)
        tmp+= "A=D+A\n"; // the currrent place on the segment
        tmp+="D=M\n"; // set D= value of the var
        tmp+="@SP\n"; //set A= "SP"
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n"; // write the var on the stack
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M+1\n"; // SP value = SP value +1

    }
    case ("pointer") {
        tmp+= "@3\n"; //set A="3" (name of register)
        tmp+="D=A\n"; //set D=3
        tmp+="@" + index +"\n";//set A = index (push segment index)
        tmp+= "A=D+A\n"; // the currrent place on the segment (5+ index)
        tmp+="D=M\n"; // set D= value of the var RAM[3+x]
        tmp+="@SP\n"; //set A= "SP"
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n"; // write the var on the stack
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M+1\n"; // SP value = SP value +1

    }
    case ("temp") {
        tmp+= "@5\n"; //set A="5" (name of register)
        tmp+="D=A\n"; //set D=5
        tmp+="@" + index +"\n";//set A = index (push segment index)
        tmp+= "A=D+A\n"; // the currrent place on the segment (5+ index)
        tmp+="D=M\n"; // set D= value of the var M[5+x]
        tmp+="@SP\n"; //set A= "SP"
        tmp+="A=M\n"; // A=M=RAM[A]=RAM[SP]
        tmp+="M=D\n"; // write the var on the stack
        tmp+="@SP\n"; // set A= "SP"
        tmp+="M=M+1\n"; // SP value = SP value +1

    }
    else {}

    return tmp;
}


//---------------------------------------------Targil 2-----------------------------------------------//


variable Integer funCounter = 0;//For functions call


String labelFun(String line,String nameOfFile){

    {String*} sentence = line.split();

    String? nameOfLable = sentence.rest.first; //name of lable
    assert(exists nameOfLable);

    variable String tmp="";
    tmp+="//****************************** Lable Strat**************************************\n";

    tmp+="("+ nameOfFile+ "."+ nameOfLable + ")" + "\n"; //first lable commands
    tmp+="//****************************** Lable End**************************************\n";

    return tmp;
}

String gotoFun(String line,String nameOfFile){
    variable String tmp="";
    tmp+="//*****************************Goto Start**************************************\n";

    {String*} sentence = line.split();

    String? nameOfLable = sentence.rest.first; //name of lable
    assert(exists nameOfLable);
    tmp+="@"+ nameOfFile+ "."+ nameOfLable + "\n";
    tmp+="0;JMP\n";
    tmp+="//****************************** Goto End**************************************\n";

    return tmp;
}

String functionFun(String line){

    variable String tmp="";
    {String*} sentence = line.split();

    String? nameOfFunc = sentence.rest.first; //The name of  the function
    String? localVariables = sentence.rest.rest.first; //The number of the local variables
    assert(exists nameOfFunc);
    assert(exists localVariables);
    tmp+="//****************************** create functin " + nameOfFunc + " Start**************************************\n";
    tmp+="(" + nameOfFunc +")"+"\n";
    tmp+="@" + localVariables +"\n";
    tmp+="D=A\n";
    tmp+="@EndFunc" +counter.string+ "\n";
    tmp+="D;JEQ\n";
    tmp+="(HeadLoop" +counter.string+ ")\n";
    tmp+="@SP\n";
    tmp+="A=M\n";
    tmp+="M=0\n";
    tmp+="@SP\n";
    tmp+="M=M+1\n";
    tmp+="@HeadLoop" +counter.string+ "\n";
    tmp+="D=D-1\n";
    tmp+="D;JNE\n";
    tmp+="(EndFunc" +counter.string+ ")\n";
    counter++;
    tmp+="//****************************** create functin " + nameOfFunc + " End**************************************\n";


    return tmp;
}


String callFun(String line){

    {String*} sentence = line.split();

    String? nameOfFunc = sentence.rest.first; //The name of  the function
    String? localVariables = sentence.rest.rest.first; //The number of the local variables
    variable String tmp="";
    assert (exists nameOfFunc);
    //push return address
    tmp+="//****************************** Call functin " + nameOfFunc + " strat**************************************\n";

    tmp+="@"+ nameOfFunc+".ReturnAddress"+ funCounter.string+" \n";
    tmp+="D=A\n";
    tmp+="@SP\n";
    tmp+="A=M\n";
    tmp+="M=D\n";
    tmp+="@SP\n";
    tmp+="M=M+1\n";
    //push LCL ,saved reg for caller func
    tmp+="@LCL\n";
    tmp+="D=M\n";
    tmp+="@SP\n";
    tmp+="A=M\n";
    tmp+="M=D\n";
    tmp+="@SP\n";
    tmp+="M=M+1\n";
    //push ARG ,saved reg for caller func
    tmp+="@ARG\n";
    tmp+="D=M\n";
    tmp+="@SP\n";
    tmp+="A=M\n";
    tmp+="M=D\n";
    tmp+="@SP\n";
    tmp+="M=M+1\n";
    //push THIS ,saved reg for caller func
    tmp+="@THIS\n";
    tmp+="D=M\n";
    tmp+="@SP\n";
    tmp+="A=M\n";
    tmp+="M=D\n";
    tmp+="@SP\n";
    tmp+="M=M+1\n";
    //push THAT ,saved reg for caller func
    tmp+="@THAT\n";
    tmp+="D=M\n";
    tmp+="@SP\n";
    tmp+="A=M\n";
    tmp+="M=D\n";
    tmp+="@SP\n";
    tmp+="M=M+1\n";


    assert (exists localVariables);
    Integer? x = parseInteger(localVariables.string);
    assert (exists x);
    value numOfArgs = x + 5;

    tmp+="@" + numOfArgs.string+ "\n";
    tmp+="D=A\n";
    tmp+="@SP\n";
    tmp+="D=M-D\n";
    tmp+="@ARG\n";
    tmp+="M=D\n";


    //ARG for called func
   // tmp+="@SP\n";
    //tmp+="D=M\n";
    //tmp+="@" + numOfArgs.string+ "\n";
    //tmp+="D=D-A\n";
    //tmp+="@ARG\n";
    //tmp+="M=D\n";

    //callad LCL=SP
    tmp+="@SP\n";
    tmp+="D=M\n";
    tmp+="@LCL\n";
    tmp+="M=D\n";
//GOTO to the func
    tmp+="@" +nameOfFunc+"\n";
    tmp+="0;JMP\n";
    //label for RA
    tmp+="("+nameOfFunc+ ".ReturnAddress" + funCounter.string+ ")\n";
    funCounter++;
    tmp+="//****************************** create functin " + nameOfFunc + "End **************************************\n";

    return tmp;
}

String returnFun(){
    variable String tmp="";
    //frame=LCL
    tmp+="//****************************** Return functin Strat**************************************\n";

    tmp+="@LCL\n";
    tmp+="D=M\n";
    //return to frame-5
    tmp+="@5\n";
    tmp+="A=D-A\n";
    tmp+="D=M\n";
    tmp+="@13\n";
    tmp+="M=D\n";//RAM[13]=LCL-5

    //ARG=POP()
    tmp+="@SP\n";
    tmp+="M=M-1\n";
    //tmp+="@SP\n";
    tmp+="A=M\n";
    tmp+="D=M\n";
    tmp+="@ARG\n";
    tmp+="A=M\n";
    tmp+="M=D\n";
    //new SP
    tmp+="@ARG\n";
    tmp+="D=M\n";//D=RAM[ARG]
    tmp+="@SP\n";
    tmp+="M=D+1\n";//RAM[SP]=D+1
    //GETTING BACK ALL THE CALLER REG THAT THIS ARG LCL
    //THAT
    tmp+="@LCL\n";
    tmp+="M=M-1\n";
    tmp+="A=M\n";
    tmp+="D=M\n";
    tmp+="@THAT\n";
    tmp+="M=D\n";
    //THIS
    tmp+="@LCL\n";
    tmp+="M=M-1\n";
    tmp+="A=M\n";
    tmp+="D=M\n";
    tmp+="@THIS\n";
    tmp+="M=D\n";
    //ARG
    tmp+="@LCL\n";
    tmp+="M=M-1\n";
    tmp+="A=M\n";
    tmp+="D=M\n";
    tmp+="@ARG\n";
    tmp+="M=D\n";
    //LCL
    tmp+="@LCL\n";
    tmp+="M=M-1\n";
    tmp+="A=M\n";
    tmp+="D=M\n";
    tmp+="@LCL\n";
    tmp+="M=D\n";
    //goto the caller func
    tmp+="@13\n";
    tmp+="A=M\n";
    tmp+="0;JMP\n";
    tmp+= "//****************************** create functin End **************************************\n";

    return tmp;

}


String if_gotoFun(String line,String nameOfFile){

    {String*} sentence = line.split();

    String? nameOfLable = sentence.rest.first; //name of lable
    assert(exists nameOfLable);


    variable String tmp="";
    tmp+= "//****************************** if_gotoFun Start **************************************\n";

    tmp+= "@SP\n";//A=SP
    tmp+="M=M-1\n";//SP--
    tmp+="A=M\n";// A=RAM[SP]
    tmp+="D=M\n";//The value of the top (in the stack)
    tmp+="@"+ nameOfFile+ "."+ nameOfLable + "\n"; //A = lable
    tmp+="D;JNE\n";//if D == -1 jump
    tmp+= "//****************************** if_gotoFun End **************************************\n";
    return tmp;

}


String  init()
{
    variable String tmp="";

    tmp+="@256\n";
    tmp+="D=A\n";
    tmp+="@SP\n";
    tmp+="M=D\n";
    tmp+=callFun("call Sys.init 0");
    return tmp;
}