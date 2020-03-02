#!/usr/bin/python3
# -*- coding:utf-8 -*-

#作者：冰枫火灵X<1079092922@qq.com>
#许可：仅保留署名权

import os

print("欢迎使用")

fn = str(input("Mod tr文件名称（不包括.zh_CN.tr）："))+".zh_CN.tr"

if os.access(fn,os.F_OK):
    pass
else:
    print("文件不存在.")
    x = input("END.")
    os._exit(0)

fn2 = str(fn.replace("CN","TW"))

os.system("opencc -c s2tw -i {0:s} -o {1:s}".format(fn,fn2))

x = input("END.")
os._exit(0)
