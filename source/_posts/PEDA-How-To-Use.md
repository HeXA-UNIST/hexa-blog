title: PEDA - How To Use
date: 2015-02-26 00:17:00
tags:
- l34p
- exploit
- gdb
---
이번 포스팅에서는 PEDA에는 어떤 기능들이 있는지, 실제로 어떤식으로 활용할 수 있는지에 대해 살펴보도록 하겠습니다.

## PEDA 기본 인터페이스

<p align="center"> <img src="/img/peda-how-to1.png" style="width: 80%;"/> </p>

우선 PEDA의 기본적인 화면은 위와 같습니다.

display 같은 걸 해주지 않으면 기본적으로 화면에 아무것도 안 나오는 gdb와 달리 PEDA는 기본적으로 현재 레지스터의 상태와 실행 중인 명령어와 그 주변 명령어들, 스택의 내용물 등을 표시해줍니다.

특히나 정말 멋진 기능 중 하나는 포인터를 따라가서 그 내용물까지 보여주는 기능입니다.
위 그림에서 레지스터 부분이나 스택 부분을 보면 포인터를 따라가서 그 안의 내용까지 보여주는 걸 볼 수 있습니다. PEDA 짱짱맨!!

그러면 이제 PEDA의 다양한 기능들을 하나씩 하나씩 들여다보겠습니다.



## pdisas

<p align="center"> <img src="/img/peda-how-to2.png" style="width: 80%;"/> </p>

pdisas는 gdb에서 쓰던 disas 명령어의 확장판입니다.

위 그림을 보면 알 수 있듯이 pdisas를 사용하면 알록달록한! 컬러풀한! 가독성이 더 높아진 버전의 disas 결과물을 볼 수 있습니다. PEDA는 gdb의 확장이므로 물론 원래 gdb의 기능들도 모두 사용 가능합니다. 그래서 pdisas 와 disas를 위 그림처럼 비교해보면 확실히 pdisas가 컬러링이 잘 돼있어 가독성이 높은 걸 알 수 있습니다.

### How to use

```bash
gdb-peda$ pdisas "Function Name"
```

### Example

```bash
gdb-peda$ pdisas main
```


## context code / register / stack

<p align="center"> <img src="/img/peda-how-to3.png" style="width: 80%;"/> </p>

context 명령어는 별다른 기능이 아니라 맨 처음에 보여드렸던 PEDA 기본인터페이스 에서 code영역 register영역 stack영역을 따로 따로 볼 수 있는 기능입니다.

### How to use

```bash
gdb-peda$ context "code/register/stack/all" ( context 만 입력시엔 context all 과 같습니다. )
```

### Example

```bash
gdb-peda$ context
gdb-peda$ context code
gdb-peda$ context all
```

## session save / restore

<p align="center"> <img src="/img/peda-how-to4.png" style="width: 80%;"/> </p>

session 명령어! 정말 편리한 기능을 제공하는 명령어입니다. 
기존 gdb에서는 열심히 분석하면서 break point도 걸어놓고 watch point도 걸어놓고 해 놓더라도 gdb를 껐다 다시 키면 전부 없어지는데 peda에서는 session이라는 명령어로 break point와 같은 설정들을 저장하고 불러오는게 가능합니다.

위 그림에서도 맨 처음에 info b 를 했을때, "No breakpoints or watchpoints" 가 나오는데 session restore 명령어를 치고 난 후 info b 를 해보면 저장해 놓았던 설정들을 그대로 가져오는 것을 볼 수 있습니다. 

### How to use

```bash
gdb-peda$ session save "파일이름" ( 파일이름 생략시엔 peda-session-"실행파일이름".txt 로 저장 )
gdb-peda$ session restore "파일이름" ( 파일이름 생략시엔 peda-session-"실행파일이름".txt 로드 )
```

### Example

```bash
gdb-peda$ session save
gdb-peda$ session restore
gdb-peda$ session save MySession
gdb-peda$ session restore MySession
```

## snapshot save / restore 

이것도 상당히 재밌는 기능인데, session 이 break point나 watch point 들을 저장하고 불러온다면 이 명령어는 아예 현재 디버깅중인 프로세스의 스냅샷을 찍어 저장하고 불러올수있게 합니다. 사용법은 session과 동일합니다.


## vmmap

<p align="center"> <img src="/img/peda-how-to5.png" style="width: 80%;"/> </p>


이 명령어는 현재 디버깅 중인 프로세스의 Virtual Memory MAP을 보여줍니다. 
그냥 vmmap 만 입력할 시에는 vmmap all 과 같으며 위 그림과 같이 vmmap binary, vmmap stack 이런 식으로 특정 메모리 영역만 볼 수도 있습니다.

원래 gdb로 했었더라면 현재 프로세스의 pid를 알아내고 shell cat /proc/"pid"/maps 를 해서 봐야 했을 텐데 PEDA를 사용하면 아주 간단하게 메모리 매핑 상태를 보는 게 가능합니다.

여기서 추가적으로 더 나아가서 얘기하자면, vmmap stack을 사용해서 현재 stack의 권한을 보고 해당 바이너리가 NX가 걸렸는지 안 걸렸는지도 알 수 있습니다.

### How to use

```bash
gdb-peda$ vmmap "all/binary/libc/stack/ld ..." ( 인자를 생략할 시에는 vmmap all 과 같습니다. )
```

### Example

```bash
gdb-peda$ vmmap
gdb-peda$ vmmap libc
gdb-peda$ vmmap stack
```



## checksec

<p align="center"> <img src="/img/peda-how-to6.png" style="width: 80%;"/> </p>

이 명령어는 현재 바이너리에 걸려있는 보안 기법들을 보여줍니다. 사용법은 간단히 그냥 checksec을 입력하기만 하면됩니다. 근데 여기서 주의해야 할 게 다른 건 몰라도 여기서 표시되는 NX는 별로 신뢰하지 않는 게 좋습니다. 버그가 있는지는 몰라도 NX가 안 걸려있는데 걸려있다고 나온다던가... 이런 경우가 몇 번 있어서 통수 맞은 적이 있네요 ㅠㅠ

그래서 밑에서 소개할 nxtest 라는 명령어 또는 vmmap stack과 같은 명령어로 다른방법을  사용해서 NX는 따로 체크해주시는게 좋을 것 같습니다.  


### How to use

```bash
gdb-peda$ checksec
```

## nxtest

<p align="center"> <img src="/img/peda-how-to7.png" style="width: 80%;"/> </p>


nxtest는 말그대로 NX 가 걸려있는지 테스트 해주는 명령어로 스택에 실행권한이 있는지 체크합니다. 


### How to use

```bash
gdb-peda$ nxtest
```

## procinfo / getpid

<p align="center"> <img src="/img/peda-how-to8.png" style="width: 80%;"/> </p>

procinfo 는 현재 디버깅중인 프로세스의 정보를 위 그림과 같이 표시해 줍니다. 
pid만 필요하다면 getpid 명령어를 사용하는걸로 pid만 얻을수도 있습니다.

### How to use

```bash
gdb-peda$ procinfo
gdb-peda$ getpid
```



## elfsymbol

<p align="center"> <img src="/img/peda-how-to9.png" style="width: 80%;"/> </p>


이게 또 참 편리한 기능인데, elfsymbol이라는 명령어로 현재 디버깅 중인 바이너리의 plt 주소, got 주소 등을 알 수 있습니다. exploit 코드를 작성할 때 got overwrite을 한다거나 got 주소를 leak 시켜온다거나 여러 가지의 상황에서 plt 주소와 got 주소가 필요한 경우가 종종 있는데 이럴때 elfsymbol 명령어를 이용하면 아주 쉽게 정보를 얻을 수 있습니다.


### How to use

```bash
gdb-peda$ elfsymbol "symbol" ( 인자를 생략하면 symbol들을 모두 보여줍니다. )
```

### Example

```bash
gdb-peda$ elfsymbol
gdb-peda$ elfsymbol printf
```


## elfheader

<p align="center"> <img src="/img/peda-how-to10.png" style="width: 80%;"/> </p>

elfheader 명령어는 현재 디버깅 중인 바이너리의 헤더 정보들을 보여줍니다. 이 기능도 exploit 코드를 작성할 때 종종 bss 영역의 주소가 필요하다거나 하는 경우가 있는데 이럴 때 사용하면 유용합니다.

### How to use

```bash
gdb-peda$ elfheader
```

### Example

```bash
gdb-peda$ elfheader
gdb-peda$ elfheader .bss
```


## find / searchmem

<p align="center"> <img src="/img/peda-how-to11.png" style="width: 80%;"/> </p>

find와 searchmem 은 동일한 명령어로 아무거나 선호하는 걸로 사용하시면 되며, 이 명령어는 메모리 영역에서 특정 패턴을 찾아줍니다. 
다양한 방법으로 응용될 수 있는데, 몇가지 예시를 들자면 위 그림과 같이 /bin/sh 문자열의 주소를 찾는다던가 특정 OPCODE를 메모리에서 찾는다던가 하는게 가능합니다.

### How to use

```bash
gdb-peda$ find/searchmem "pattern" "범위" ( 범위부분을 생략하면 binary 영역으로 세팅 됩니다.)
```

### Example

```bash
gdb-peda$ find /bin/sh libc
```


## ropgadget / ropsearch / dumprop

<p align="center"> <img src="/img/peda-how-to12.png" style="width: 80%;"/> </p>

ropgadget 과 ropsearch 명령어는 ROP를 할 때 필요한 가젯들을 쉽게 찾을 수 있도록 도와주는 명령어입니다. ropgadget은 자주 쓰이는 가젯들인 pop-ret, leave-ret, add esp 와 같은 가젯들을 찾아줍니다. 또한 ropsearch는 원하는 특정 가젯을 찾을 수 있도록 도와줍니다. 

dumprop도 비슷한 명령어인데, 이 명령어는 특정 가젯을 찾기 보다 특정 메모리 영역에서 모든 가젯들을 보고 싶을 때 유용합니다. 하지만 ropsearch '' binary 이런 식으로 사용하면 ropsearch 로도 dumprop와 비슷하게 사용할 수 있습니다.

### How to use

```bash
gdb-peda$ ropgadget binary/libc/vdso/all ... ( 인자를 생략하면 ropgadget binary 와 같습니다. )
gdb-peda$ ropsearch "gadget" "범위" ( gadget 부분을 '' 로 빈 상태로 보내면 모든 가젯을 찾습니다. )
gdb-peda$ dumprop "범위" ( 인자를 생략하면 dumprop binary 와 같습니다. )
```

### Example

```bash
gdb-peda$ ropgadget
gdb-peda$ ropgadget libc
gdb-peda$ ropsearch "add esp, ?" binary
gdb-peda$ ropsearch "int 0x80" libc
gdb-peda$ ropsearch "" binary ( binary 범위에서 모든 가젯을 찾습니다. )
gdb-peda$ ropsearch "pop ?" 0x08048000 0x0804b000
gdb-peda$ dumprop binary
gdb-peda$ dumprop 0x08048000 0x0804b000
```



## jmpcall

<p align="center"> <img src="/img/peda-how-to13.png" style="width: 80%;"/> </p>

이 명령어도 ROP 할 때 유용한 가젯들을 찾아주는데, 그중 jmp와 call 가젯들을 전부 찾아줍니다. 그냥 jmpcall 만 입력하면 바이너리 영역 내의 모든 jmp, call 가젯들을 찾아주며 jmpcall esp libc 처럼 특정 메모리 영역 내의 특정 jmp, call 가젯들만 찾을 수도 있습니다.

### How to use

```bash
gdb-peda$ jmpcall "register" "범위" (인자들을 모두 생략하면 jmpcall "" binary 와 같으며, 바이너리 영영 내 모든 jmp, call 가젯들을 찾아줍니다.)
```

### Example

```bash
gdb-peda$ jmpcall
gdb-peda$ jmpcall "" libc
gdb-peda$ jmpcall esp libc
gdb-peda$ jmpcall [eax] libc
gdb-peda$ jmpcall eax ( jmpcall eax binary 와 같습니다. )
```

## shellcode

<p align="center"> <img src="/img/peda-how-to14.png" style="width: 80%;"/> </p>

PEDA에는 기본적으로 제공해주는 쉘코드가 몇 가지 있는데 shellcode generate 란 명령어로 현재 가능한 쉘코드 종류를 볼 수 있고, shellcode generate x86/linux exec 이런 식으로 지정하여 필요한 쉘코드를 바로바로 얻을 수도 있습니다.

현재 PEDA에 기본적으로 내장되어 있는 쉘코드는 x86/linux, bsd 뿐이지만 shellcode search나 display로 쉘코드를 웹에서 가져올 수도 있습니다.


### Example

```bash
gdb-peda$ shellcode generate x86/linux exec
```

이 외에도 PEDA는 많은 기능들을 제공하는데, PEDA에서 제공하는 다른 기능들도 살펴보시고 싶으시면, phelp 또는 peda help 를 입력하셔서 쭉 훑어보시면 됩니다.

PEDA 명령어나 명령어 활용법에 대해 다른 참고할만한 자료 및 사이트

1. http://ropshell.com/peda/Linux_Interactive_Exploit_Development_with_GDB_and_PEDA_Slides.pdf
2. http://security.cs.pub.ro/hexcellents/wiki/kb/toolset/peda

수정할 내용이나 더 추가할 내용이 있다면 알려주세요!

작성자: [l34p](https://github.com/L34p/)
