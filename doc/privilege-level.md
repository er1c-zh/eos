# 特权级

[toc]

## CPL RPL DPL 

### CPL

- 当前的程序或任务的特权级 current-privilege-level
- 存储在ecs中

- 当程序转移到不同特权级的代码段时，会改变CPL
- 如果遇到了一致代码段，CPL不会被改变

### RPL

- 请求权限级 request-privilege-level
- 存储在选择子中

操作系统往往使用RPL来避免低特权级应用访问高特权级中的数据。

> 操作系统过程被调用，接收到一个选择子时，会将选择子的RPL设成调用者的特权级， **避免了操作系统用自己的权限去完成调用**

### DPL

- 段或者门的特权级 descriptor-privilege-level
- 存储在描述符中

## 一些概念

### 一致代码段与非一致代码段

- 访问一致代码段时,将不会修改CPL
- 访问非一致代码段时,将会用目标代码段描述符的DPL替换为访问后的CPL

### 跳转的方式

- 直接跳转,即使用 ```call``` 或者 ```jmp``` 加段选择符:偏移地址跳转
- 使用调用门
    使用调用门时,如果成功调用到调用门,cpu将会将目标代码段的RPL清零

## 规则

### 数据段和堆栈段和TSS

要求访问者的CPL和RPL要小于等于目标段的DPL

### 代码段和调用门

1. 一致代码段 直接跳转
    CPL >= DPL (RPL不检查)
2. 一致代码段 调用门
    max{CPL, RPL} <= gate.DPL _(访问数据段和堆栈段的规则)_ && CPL >= dest.DPL
3. 非一致代码段 直接跳转
    CPL == DPL && RPL <= DPL (最后这个条件,估计是要满足 _CPL和RPL中数值较大的起决定性作用_)
4. 非一致代码段 调用门
    1. call
        max{CPL, RPL} <= gate.DPL && CPL >= dest.DPL
    2. jmp
        max{CPL, RPL} <= gate.DPL && CPL == dest.DPL

## 参考

- [DPL,RPL,CPL 之间的联系和区别](https://blog.csdn.net/better0332/article/details/3416749) _很好,讲的很清楚_
- _Orange'S 一个操作系统的实现_
