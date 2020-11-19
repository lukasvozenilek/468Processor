//Increment
MOV R0 #1
//Max value
MOV R1 #100
//Starting memory address
MOV R2 #30

//Start of loop
//Add increment to R3
ADD R3 R3 R0
//Store R3 to R2 location in RAM
STR R3 R2
//Check for max
CMP R3 R1
B LT 3