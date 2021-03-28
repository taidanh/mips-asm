# MIPS Assmebly
An example of a basic graphics on MIPS assmebly

## Usage

> This program requires [MARS](https://courses.missouristate.edu/KenVollmar/mars/download.htm) and Java.

Put MARS in the same directory with the provided assmebly files
then you can open those files in MARS and run `lab5_s20_test.asm`
after opening the Bitmap Display under Tools > Bitmap Display and
changing the base address to `0xffff0000` (memory map)

Output after running the test file:

<img width="256" alt="output" src="https://user-images.githubusercontent.com/65222208/112745747-828ee500-8f5f-11eb-9c72-dc8a52cd45ac.png">

Separate use cases can be found in the test files as examples, such as:

```
# cyan point at  (1,1)
li $a0, 0x00010001
lw $a1, cyan
jal draw_pixel
```
