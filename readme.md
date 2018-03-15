# EOS
## build
1. 修改boot.bxrc中的路径
    1. romimage
    1. vagromimage
    1. floppya
1. ```make```
1. 启动bochs
## 遇到的问题
### 保护模式
1. **no bootable device** 就是生成的镜像里面 没有符合约定的将510处置为0xaa55