.data
arr: .space 40        # Reserve space for 5 integers (5 * 4 bytes)
arrS: .word 10         # Array size (5 elements)

.macro print_int
    li a7, 1
    ecall
.end_macro
.macro read_int
    li a7, 5
    ecall
.end_macro
.macro print_array
    mv a0, s0
    mv a1, s1
    call PRINT_ARRAY
.end_macro
.macro new_line
    li a7, 11
    li a0, 10
    ecall
.end_macro
.macro space
    li a7, 11
    li a0, 32
    ecall
.end_macro

.text
MAIN:
    la s0, arr        # s0 = address of the array (arr)
    lw s2, arrS       # s2 = number of elements in the array
    slli t0, s2, 2
    add s1, s0, t0    # s1 = address after the last element (arr + size)

    # Take input from the user
    mv t0, s0         # Iterator t0 starts at arr
    mv t1, s1         # End pointer t1 = arr + size
INPUT_LOOP:
    beq t0, t1, INPUT_DONE # If t0 == s1, all elements are input
    read_int()              # Read an integer from the user
    sw a0, 0(t0)            # Store the input at t0
    addi t0, t0, 4          # Move to the next position
    j INPUT_LOOP
INPUT_DONE:

    # Print the original array
    print_array()

    # Bubble sort
    mv s10, zero      # Loop counter
MAIN_LOOP:
    beq s10, s2, MAIN_DONE
    mv a0, s0
    mv a1, s1
    call ARRAY_PAIRS
    addi s10, s10, 1
    j MAIN_LOOP
MAIN_DONE:

    # Print the sorted array
    print_array()

    j EXIT

# Prints all elements of the array
PRINT_ARRAY:
    mv t0, a0        # t0 = a0 = start of the array
    mv t1, a1        # t1 = a1 = end of the array
PRINT_LOOP:
    beq t0, t1, PRINT_DONE # If t0 == t1, done
    lw t2, 0(t0)           # Load element at t0 into t2
    mv a0, t2
    print_int()            # Print the element
    space()                # Print a space
    addi t0, t0, 4         # Move to the next element
    j PRINT_LOOP
PRINT_DONE:
    new_line()
    jr ra

# Iterate through the array once, swapping unordered pairs
ARRAY_PAIRS:
    mv t0, a0        # t0 = start of the array
    addi t1, a1, -4  # t1 = end - 4 (last valid pair start)
PAIRS_LOOP:
    beq t0, t1, PAIRS_DONE # If t0 == t1, done
    lw t2, 0(t0)           # Load current element into t2
    lw t3, 4(t0)           # Load next element into t3
    bgt t3, t2, PAIRS_OK   # If t3 > t2, skip swap
    sw t2, 4(t0)           # Swap elements
    sw t3, 0(t0)
PAIRS_OK:
    addi t0, t0, 4         # Move to the next pair
    j PAIRS_LOOP
PAIRS_DONE:
    jr ra

EXIT:
    li a7, 10
    ecall
