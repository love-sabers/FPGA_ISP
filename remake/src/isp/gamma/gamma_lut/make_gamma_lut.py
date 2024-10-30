import numpy as np
import os

source = np.arange(256).astype(float)
# 定义Gamma值
gamma = 1
# 应用Gamma校正
gamma_corrected = np.power(source / 255.0, 1.0/gamma) * 255.0
# 将结果转换为8位整数
gamma_corrected = np.uint8(np.clip(gamma_corrected, 0, 255))

current_dir = os.path.dirname(os.path.abspath(__file__))
filename="gamma_lut"+str(gamma).replace('.','p')+".txt"
file_path = os.path.join(current_dir, filename)

with open(file_path, 'w') as f:
    for val in gamma_corrected:
        f.write(hex(val)[2:].zfill(2).upper()+'\n')