I89 = /home/eric/mysrc/i89/asi89

all: 14458x-check 147931-check

%.hex %.lst: %.asm
	$(I89) 14458x.asm -o 14458x.hex -l 14458x.lst

%.bin: %.hex
	srec_cat 14458x.hex -intel -o 14458x.bin -binary

14458x-orig.bin: 144580-001.bin 144581-001.bin
	srec_cat -o 14458x-orig.bin -binary \
		144580-001.bin -binary -unsplit 2 0 \
		144581-001.bin -binary -unsplit 2 1

14458x-check: 14458x.bin
	echo "50e994d907e16e4fa237b50b7f41a5d1600459dc4901d9470de8dd5520963659 14458x.bin" | sha256sum -c -

14458x-hexdiff: 14458x-orig.bin 14458x.bin
	hexdiff 14458x-orig.bin 14458x.bin

147931-check: 147931.bin
	echo "8ad8bcac17d46ebdbbb17a2d59417f43843b516a56cb09171a72801397b8818c 147931.bin" | sha256sum -c -

147931-hexdiff: 147931-orig.bin 147931.bin
	hexdiff 147931-orig.bin 147931.bin
