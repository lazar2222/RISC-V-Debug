import sys

def main(args):
    in_file  = args[1]
    out_file = args[2]

    print(in_file, out_file)

    with open(in_file, 'r') as input_file:
        input_lines = input_file.readlines()

    output_lines = ['-- postprocessed with mif_pp.py']

    mode = 0

    for line in input_lines:
        line = line.strip()
        if line.startswith('--'):
            output_lines.append(line)
            continue
        if line == 'END;':
                mode = 0
        if mode == 0:
            output_lines.append(line)
            if line == 'CONTENT BEGIN':
                mode = 1
        else:
            line = line[:-1]
            hex_values = line.split()
            address = hex_values[0][:-1]
            address = int(address, 16)
            hex_values = hex_values[1:]
            output_lines += [f'{(hex(i + address)[2:].upper()):>04}: {hex_value};' for i, hex_value in enumerate(hex_values)]

    with open(out_file, 'w') as output_file:
        for line in output_lines:
            output_file.write(line + '\n')

if __name__ == '__main__':
    main(sys.argv)