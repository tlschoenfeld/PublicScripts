#!/usr/bin/python
# -*- coding:utf-8 -*-
import sys
import os

picdir = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), 'pic')
libdir = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), 'lib')
if os.path.exists(libdir):
    sys.path.append(libdir)

import logging
from waveshare_epd import epd2in9_V2
import time
from PIL import Image,ImageDraw,ImageFont
import traceback

logging.basicConfig(level=logging.DEBUG)

try:
    logging.info("epd2in9 V2 Demo")
    epd = epd2in9_V2.EPD()

    logging.info("init and Clear")
    epd.init()
    epd.Clear(0xFF)

    i = 0
    while i < 5:

        i += 1
        files = os.listdir('/home/pi/photos')    
        for f in files:

            logging.info("1.read bmp file")
            Himage = Image.open(os.path.join('/home/pi/photos' ,f))
            epd.display(epd.getbuffer(Himage))
            # Himage = Himage.transpose(method=Image.ROTATE_180)
            # Limage = Himage.transpose(method=Image.ROTATE_180)
            time.sleep(4)


    logging.info("Clear...")
    epd.init()
    epd.Clear(0xFF)
   
    logging.info("Goto Sleep...")
    epd.sleep()
   
except IOError as e:
    logging.info(e)
   
except KeyboardInterrupt:    
    logging.info("ctrl + c:")
    epd2in9_V2.epdconfig.module_exit()
    exit()
