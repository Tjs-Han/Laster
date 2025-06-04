
5月16
1. mpt2042_rom_128x8_2.mem rise_signal_process_v1.v
双边沿,只有stop1 采样
2. mpt2042_rom_128x8_1.mem rise_signal_process.v
单边沿,有stop1 上升采样， stop2下降采样

上述代码配套使用
需要注意
1. 双边沿采样时,上下边沿间隔最小为8ns
2. 输入的star,stop1,stop2信号脉宽必须大于4ns