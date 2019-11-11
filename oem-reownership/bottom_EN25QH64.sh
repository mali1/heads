#TODO: change script to not depend on ifdtool, considering x230-libremkey would produce 12Mb image splitted in 4Mb and 8Mb image with shrinked IFD and ME taken from blob directory
echo -e "Backuping bottom SPI flash into top.rom\n" && sudo flashrom -r ./bottom.rom --programmer ch341a_spi -c EN25QH64 && echo -e "Verifying bottom SPI flash\n" && sudo flashrom -v ./bottom.rom --programmer ch341a_spi -c EN25QH64 && echo "Unlocking ROM descriptor..." && /home/user/heads/build/coreboot-4.8.1/util/ifdtool/ifdtool -u ./bottom.rom && echo "Neutering+Deactivating ME" && python /home/user/me_cleaner/me_cleaner.py -r -t -d -S -O ./cleaned_me.rom ./bottom.rom.new --extract-me ./extracted_me.rom && echo "Flashing back Neutered+Deactivated ME in bottom SPI flash chip..." && sudo flashrom -w ./cleaned_me.rom --programmer ch341a_spi -c EN25QH64
