title: 'PEDA - Introduction && Installation'
date: 2014-02-25 23:33:00
tags:
- l34p
- exploit
---
## Introduction

PEDA는 Python Exploit Development Assistance for GDB 의 줄임말로 말 그대로 리눅스에서 디버깅할 때 흔히 사용하는 gdb에 exploit을 할때 도움이 되는  다양한 기능을 추가시켜주는 gdb python script 입니다.

밋밋한 gdb 만 쓰다 PEDA를 적용하여 사용해보시면 색도 알록달록하고 강력한 기능에 신세계를 경험하실 수 있을겁니다!

PEDA에 대한 자세한 내용은 아래의 URL에서 확인하실 수 있습니다.

1. https://github.com/longld/peda
2. http://ropshell.com/peda/


## Installation

설치 방법 및 적용 방법은 매우 간단합니다. (사실 ubuntu 최신 버전과 같이 gdb의 python 버전이 3.x 인 경우에는 쬐에에끔... 복잡할 수 있습니다.)

그래서 우선! 현재 설치하려고 하는 환경의 gdb가 어떤 버전의 python을 사용하고 있는지 확인해 보도록 하겠습니다.


gdb를 키고 python print(sys.version) 를 입력하여 python 버전을 확인합니다.

```bash
$ gdb -q
$ (gdb) python print(sys.version)
```

여기서 결과가 2.7.3 이런식으로 2 버전대로 나온다면 ,
PEDA파일을 받아오고 .gdbinit에 PEDA파일을 불러오는 내용만 추가해 주시면 됩니다.

```bash
$ git clone https://github.com/longld/peda.git ~/peda
$ echo "source ~/peda/peda.py" >> ~/.gdbinit
```

저 두줄만 입력하여 주시면 PEDA 설치와 설정이 끝나게 됩니다.

하지만... 결과가 3.4.0 이런식으로 3 버전대로 나온다면, 위 두줄의 명령어를 실행하여 PEDA를 설치한 다음 gdb를 2버전대의 python으로 새로 컴파일 해주어야 합니다. 그 과정은 아래와 같습니다.

1. 현재 설치되어 있는 gdb를 지워줍니다.
```
$ sudo apt-get remove gdb
```
2. gdb 소스를 받아옵니다.
http://ftp.gnu.org/gnu/gdb/ 여기로 들어가셔서 gdb-7.8.2.tar.gz 를 받아주시면 됩니다.
( 2015년 2월 25일 현재 7.9버전까지 있으나 7.9버전에는 오류가 발생하여 잘 안되는것 같습니다. ) 
3. 다운로드 받은 gdb-7.8.2.tar.gz 의 압축을 풀어줍니다.
```bash
$ tar -xvf "다운로드 받은 경로"/gdb-7.8.2.tar.gz
```
4. python 2.7-dev 패키지 다운로드
```bash
$ sudo apt-get install python2.7-dev
```
5. libncurses5-dev 패키지 다운로드
```bash
$ sudo apt-get install libncurses5-dev
```
6. 압축해제한 gdb소스가 있는 경로로 이동하여 아래의 내용을 입력합니다.
```bash
$ ./configure --with-python=python2
$ make
$ sudo make install  
```

<p align="center"> <img src="/img/peda.png" style="width: 40%;"/> </p>

여기까지 따라오시느라 수고 많으셨습니다!
제대로 설치가 되었다면 아래와 같은 화면을 볼 수 있습니다.

작성자: [l34p](https://github.com/L34p/)
