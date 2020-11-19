# Open memory for writing and program source for reading
RAMFile = open("data.txt", "w")
ProgramFile = open("program.asm", "r")

# Defines instruction opcode and argument requirements
InstructionDictionary = {
    "ADD": (0b0000, [4, 5]),
    "SUB": (0b0001, [4, 5]),
    "MUL": (0b0010, [4, 5]),
    "ORR": (0b0011, [4, 5]),
    "AND": (0b0100, [4, 5]),
    "EOR": (0b0101, [4, 5]),
    "MOV": (0b0110, [3, 4, 5, 6]),
    "CMP": (0b1011, [3, 4]),
    "ADR": (0b1100, [3, 4]),
    "LDR": (0b1101, [3, 4]),
    "STR": (0b1110, [3, 4]),
    "NOP": (0b1111, [1]),
    "B": (16, [2, 3])
}

# Defines condition codes
ConditionDictionary = {
    "EQ": 0b0001,
    "GT": 0b0010,
    "LT": 0b0011,
    "GE": 0b0100,
    "LE": 0b0101,
    "HI": 0b0110,
    "LO": 0b0111,
    "HS": 0b1000,
}

# Relates registers to destination number
RegisterDictionary = {
    "R0": 0b0000,
    "R1": 0b0001,
    "R2": 0b0010,
    "R3": 0b0011,
    "R4": 0b0100,
    "R5": 0b0101,
    "R6": 0b0110,
    "R7": 0b0111,
    "R8": 0b1000,
    "R9": 0b1001,
    "R10": 0b1010,
    "R11": 0b1011,
    "R12": 0b1100,
    "R13": 0b1101,
    "R14": 0b1110,
    "R15": 0b1111,
}


def PrintError(err, linenum):
    print("Compile Error on line " + str(linenum) + ": " + err)


i = 0
for line in ProgramFile:
    # Comment, skip this line
    if line[0] == "/" and line[1] == "/":
        continue

    # Skip if blank line
    if line == "\n":
        continue

    args = line.replace("\n", "").replace("#", "").split(" ")
    if args[0] not in InstructionDictionary:
        PrintError("Instruction Not Found", i)
        break
    opcode = InstructionDictionary[args[0]][0]
    argreq = InstructionDictionary[args[0]][1]

    if len(args) not in argreq:
        PrintError("Invalid Argument Count", i)
        break

    # Define all sections of the final instruction
    cond = 0
    s = 0
    dest = 0
    source2 = 0
    source1 = 0
    shift = 0
    bits = 0
    NC = 0

    # Check for suffix arguments (flag set and conditional
    if args[1] in ConditionDictionary:
        cond = ConditionDictionary[args[1]]
        argshift = 1
    elif args[1] == "S":
        if args[2] in ConditionDictionary:
            s = 1
            cond = ConditionDictionary[args[1]]
            argshift = 2
        else:
            s = 1
            argshift = 1
    else:
        argshift = 0

    # Defines branch seperately as it recodes it as MOV R15
    if opcode == 16:
        opcode = 0b0110
        location = args[1+argshift]
        args[1+argshift] = "R15"
        args.append(location)

    if opcode in range(0, 6):
        # ADD, SUB, MUL, ORR, AND, EOR
        dest = RegisterDictionary[args[1+argshift]]
        source1 = RegisterDictionary[args[2+argshift]]
        source2 = RegisterDictionary[args[3+argshift]]

    elif opcode in range(6, 11):
        # MOV
        dest = RegisterDictionary[args[1 + argshift]]
        if len(args) == 3 + argshift:
            # Immediate or copy
            # Check if copy or immediate value
            if args[2+argshift] in RegisterDictionary:
                source1 = RegisterDictionary[args[2+argshift]]
                opcode = 0b0111
            else:
                # Deconstruct immediate value into each instruction section
                im_val = int(args[2+argshift])
                bits = (im_val >> 0) & 0b111
                shift = (im_val >> 3) & 0b11111
                source1 = (im_val >> 8) & 0b1111
                source2 = (im_val >> 12) & 0b1111
                opcode = 0b0110

        elif len(args) == 5 + argshift:
            # LSR, LSL, ROR
            source1 = 0
            source2 = RegisterDictionary[args[2 + argshift]]
            shift = int(args[4 + argshift])
            if args[3 + argshift] == "LSR":
                opcode = 0b1000
            elif args[3 + argshift] == "LSL":
                opcode = 0b1001
            elif args[3 + argshift] == "ROR":
                opcode = 0b1010

    elif opcode == 11:
        # CMP
        source1 = RegisterDictionary[args[1 + argshift]]
        source2 = RegisterDictionary[args[2 + argshift]]
        dest = 0

    elif opcode == 12:
        # ADR
        pass

    elif opcode == 13:
        # LDR
        dest = RegisterDictionary[args[1 + argshift]]
        source1 = RegisterDictionary[args[2 + argshift]]

    elif opcode == 14:
        # STR
        source1 = RegisterDictionary[args[2 + argshift]]
        source2 = RegisterDictionary[args[1 + argshift]]

    elif opcode == 15:
        # NOP
        pass

    # Assemble instruction
    instruction = (cond << (32-4)) | (opcode << (28-4)) | (s << (24-1)) | (dest << (23-4)) | (source2 << (19-4)) | (source1 << (15-4)) | (shift << (11-5)) | (bits << (6-3)) | NC
    print("Instruction " + str(i) + ": " + format(instruction, '#034b'))

    # Write instruction to RAM file encoded as hex
    RAMFile.write(format(instruction, '032b') + "\n")
    i += 1

# Finally write NOP to halt simulation
RAMFile.write("00001111000000000000000000000000")
RAMFile.close()
ProgramFile.close()
