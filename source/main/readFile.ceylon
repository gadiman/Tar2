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

shared void readFile(String filePath) {
    Resource resource = parsePath(filePath).resource;
    // Resource has 4 subtypes: File | Directory | Link | Nil
    // We have to resolve the type.
    if (is File resource) {
        variable String textOfFile="";
        variable String dict = resource.directory.string;

        forEachLine(resource, (String line) {

            {String*} firstWords = line.split();
            String? firstWord = firstWords.first;


            value index =resource.name.indexOf(".");
            variable String nameOfFile = resource.name.substring(0,index);

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
                textOfFile += callFun();
              }
            case ("function") {
                textOfFile += functionFun();
              }
            case ("return")   {
                textOfFile += returnFun();
               }
            else {  }
        });

        String pathForAsmFile = changeNameOfSuffix(resource.name,dict);
        writeFileAsm(pathForAsmFile,textOfFile);
        textOfFile ="";


    }



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


String labelFun(String line,String nameOfFile){

    {String*} sentence = line.split();

    String? nameOfLable = sentence.rest.first; //name of lable
    assert(exists nameOfLable);

    variable String tmp="";
    tmp+="("+ nameOfFile+ "."+ nameOfLable + ")" + "\n"; //first lable commands
    return tmp;
}

String gotoFun(String line,String nameOfFile){
    variable String tmp="";
    {String*} sentence = line.split();

    String? nameOfLable = sentence.rest.first; //name of lable
    assert(exists nameOfLable);
    tmp+="@"+ nameOfFile+ "."+ nameOfLable + "\n";
    tmp+="0;JMP\n";
    return tmp;
}

String functionFun(){
    variable String tmp="";

    return tmp;
}


String callFun(){
    variable String tmp="";

    return tmp;
}

String returnFun(){
    variable String tmp="";

    return tmp;
}


String if_gotoFun(String line,String nameOfFile){

    {String*} sentence = line.split();

    String? nameOfLable = sentence.rest.first; //name of lable
    assert(exists nameOfLable);


    variable String tmp="";
    tmp+= "@SP\n";//A=SP
    tmp+="M=M-1\n";//SP--
    tmp+="A=M\n";// A=RAM[SP]
    tmp+="D=M\n";//The value of the top (in the stack)
    tmp+="@"+ nameOfFile+ "."+ nameOfLable + "\n"; //A = lable
    tmp+="D;JNE\n";//if D == -1 jump

    return tmp;
}



