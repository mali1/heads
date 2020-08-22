
#The ME blobs dumped in this directory come from the following link: https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/thinkpad-t-series-laptops/thinkpad-t430/downloads/DS032435

#You can arrive to the same result by doing the following:
wget https://download.lenovo.com/pccbbs/mobiles/g1rg24ww.exe && innoextract g1rg24ww.exe && python ~/me_cleaner/me_cleaner.py -r -t -O ~/heads/blobs/xx30/me.bin app/ME8_5M_Production.bin

#sha256sums:
#f60e1990e2da2b7efa58a645502d22d50afd97b53a092781beee9b0322b61153  g1rg24ww.exe
#821c6fa16e62e15bc902ce2e958ffb61f63349a471685bed0dc78ce721a01bfa  app/ME8_5M_Production.bin
#c140d04d792bed555e616065d48bdc327bb78f0213ccc54c0ae95f12b28896a4  blobs/x230/me.bin

#x230-ifd.bin is extracted from an external flashrom backup (no way found to be able to extract it from Lenovo firmware upgrades as of now):
#python ~/me_cleaner/me_cleaner.py -S -r -t -d -O discarded.bin -D ~/haeds/blobs/xx30/x230-ifd.bin -M temporary_me.bin x230_bottom_spi_backup.rom

#sha256sum:
#68c1e9be8e2f99b2432e86219515f7f2fea61a4d00c7f9ea936d76d9dab2869b  blobs/x230/x230-ifd.bin

#ls -al blobs/x230/*.bin
#-rw-r--r-- 1 user user  4096 Mar 15 12:55 blobs/x230/x230-ifd.bin
#-rw-r--r-- 1 user user 98304 Mar 15 14:33 blobs/x230/me.bin

#blobs/x230/gbe.bin is generated per bincfg from the following coreboot patch: https://review.coreboot.org/c/coreboot/+/44510 
#And then by following those instructions:
# Use this target to generate GbE for X220/x230
#gen-gbe-82579LM:
	./bincfg gbe-82579LM.spec gbe-82579LM.set gbe1.bin
	# duplicate binary as per spec
	cat gbe1.bin gbe1.bin > ../../../../blobs/xx30/gbe.bin
	rm -f gbe1.bin

#sha256sum:
#9f72818e23290fb661e7899c953de2eb4cea96ff067b36348b3d061fd13366e5  blobs/xx30/gbe.bin


#Notes: as specified in first link, this ME can be deployed to:
#    Helix (Type 3xxx)
#    T430, T430i, T430s, T430si, T431s
#    T530, T530i
#    W530
#    X1 Carbon (Type 34xx), X1 Helix (Type 3xxx), X1 Helix (Type 3xxx) 3G
#    X230, X230i, X230 Tablet, X230i Tablet, X230s
