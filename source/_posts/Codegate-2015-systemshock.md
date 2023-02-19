title: Codegate 2015 - systemshock
date: 2015-04-06 12:20:08
author: l34p
tags:
- l34p
- codegate
- ctf
- writeup
---
200점짜리 문제로, 많은 팀들이 가장먼저 푼 문제입니다. 

문제가 나오고 정말빨리 풀렸는데, 저는 처음에 문제 제목에 현혹되어 [shellshock][shellshock]인줄 알고 헤메느라 시간이 많이 걸렸네요... ㅠㅠ
실제로 당황스럽게도 대회 서버에서 [CVE-2014-6277][CVE-2014-6277]이 먹혔더라죠... ;;

하지만 차분히 생각해보면 [shellshock][shellshock]는 `setuid`가 걸려있는 바이너리안에서 `bash`를 호출해야한다는 점과 환경변수를 필요로 한다는점을 생각해보면 이 문제에서는 [shellshock][shellshock]를 사용할 수 없다는걸 바로 알 수 있습니다.

이걸 생각못해서 날린 시간이 몇시간인지.. 흙흙

여튼, 이 문제는 [shellshock][shellshock]를 이용해서 푸는 문제가 아닌 strcat을 이용한 단순한 오버플로우 문제입니다. 제대로 된 풀이만 바로 떠올리면 정말 빨리 풀 수 있는 문제이지요... 실제로 문제가 나오자마자 엄청 빠른 속도로 풀린 문제이기도 합니다.

그럼 각설하고 풀이로 들어가보도록 하겠습니다!

## 문제환경

<p align="center"> <img src="/img/systemshock1.png" style="width: 90%;"/> </p>

오호 정확히 `strlen`의 인자로 넣어준 A들이 들어간것을 볼 수 있습니다.

그럼 이제 해야할것은 `argv[1]`의 포인터를 덮어씌우기 위해 앞에 몇개의 A를 넣어줘야하는지와 어떤 값으로 덮어써야할지를 정하면 되겠습니다.

어떤값으로 덮어써야할지는 비어있는 문자열 즉 null이 들어있는 주소로 덮어주면 됩니다. 그러면 `strlen`의 리턴값이 0이 되고, 입력값 검사를 우회할수 있게 됩니다. 그런데 여기서 또 생각해 줘야할 부분이 서버에는 ASLR이 걸려있어 주소들이 랜덤이고 32비트가 아니라 ulimit -s unlimited 같은 꼼수도 못부립니다 ㅠㅠ.. 하지만! 64비트에도 고정인 주소가 있으니... 바로 그부분은 vsyscall 영역입니다.

<p align="center"> <img src="/img/systemshock2.png" style="width: 80%;"/> </p>

끝부분에 보이는 

```
0xffffffffff600000    0xffffffffff601000 r-xp      [vsyscall]
```

부분은 ASLR이 걸려있더라도 고정인 주소로 매핑됩니다. 그렇다면 이 vsyscall 영역에 null이 들어있는 주소가있다면?! 그 주소로 `strlen`의 인자, 즉 argv[1]의 포인터를 덮어씌우면 끝나게 됩니다.

그러면 이제 이 vsyscall 영역에 null문자열이 있는지 한번 찾아봅시다.

<p align="center"> <img src="/img/systemshock3.png" style="width: 90%;"/> </p>

찾는방법은 여러가지 있겠으나 저는 peda의 searchmem 기능을 이용하여 찾았습니다.
vsyscall 영역에서 null(0x00) 으로 찾으니 꽤 많이 나오는데 이 중에서 값의 중간에 0x00 널값이 포함안되는 값으로 아무거나 하나 정해주면됩니다.

null이 들어가면 안되는 이유는 문제 바이너리를 실행할때 인풋을 argv[1]로 넘겨주는데 이 argv[1]은 중간에 null값이 들어갈 수 없기 때문입니다. ( null 값이 들어가면 null뒤의 값들은 짤립니다.. ㅠㅠ )

여튼 그럼 저는 적당히 0xffffffffff600405 로 골라서 하도록 하겠습니다.

이제 남은일은 앞에 더미값인 A를 몇개나 입력해줘야하는가 인데, 자세히 분석해서 알아낼 수도 있겠지만 대회 특성상 문제를 빨리풀어야하는걸 고려해서 peda의 pattern 명령어를 사용하여 자세히 분석하지 않고도 쉽게 알아낼수 있는 방법을 쓰도록 하겠습니다.

<p align="center"> <img src="/img/systemshock4.png" style="width: 85%;"/> </p>

pattern create 1024 pattern.txt 를 입력하면 pattern.txt 라는 파일에 1024개의 패턴 문자가 쓰여지게 됩니다.
그리고 실행할때 r `cat pattern.txt` 로 실행을 하면 방금 만든 pattern 값들을 argv[1]로 넘기면서 실행할 수 있습니다.

이렇게 실행을 하면,

<p align="center"> <img src="/img/systemshock5.png" style="width: 85%;"/> </p>

이렇게 `strlen`의 인자가 패턴값으로 덮힌것을 알 수 있습니다.

이상태에서 pattern.txt 파일을 열어 ANsA8sAi 의 문자열을 찾아 ( 리틀엔디안이므로 문자열을 뒤집은 것입니다. ) 이 문자열앞의 문자 갯수를 python len 함수같은것을 이용하여 세어봐도 되고, peda의 pattern search 라는 기능을 이용해도 됩니다.

<p align="center"> <img src="/img/systemshock6.png" style="width: 85%;"/> </p>

pattern search를 해보면 offset이 525로 나오는데 이게 우리가 구할 offset과 일치합니다.

이렇게 offset을 구했으니 "A" 525개 + "B" 8개 를 넣어서 offset이 맞는지 한번 확인해보도록 하겠습니다.

<p align="center"> <img src="/img/systemshock7.png" style="width: 90%;"/> </p>

`strlen`에 breakpoint를 걸은후, `perl -e'print"A"x525, "B"x8'` 로 실행시키면 정확히 `strlen`의 인자로 BBBBBBBB가 들어가는것을 볼 수 있습니다.

그럼 이제 BBBBBBBB 부분 대신에 아까 구해준 null이 들어있는 주소,  0xffffffffff600405 으로 대신 넣어주고 "A"525개에 A만 넣는게 아니라 실행시킬 명령어도 포함시켜 주면 입력값 검사를 안받게되고 임의의 명령어를 실행시킬수 있게 됩니다.

## Exploit Code

```python
# exploit.py
# ./shock "`cat payload`"
from struct import pack

f = open("payload", "w")

null_addr=0xffffffffff600405
cmd="HACKED;cat flag;/bin/sh;#"

payload = cmd + "A"*(525-len(cmd))
payload+= pack("<Q", null_addr)

f.write(payload)
f.close()
```

![](/img/systemshock8.png)

궁금한부분이 있거나 수정할 부분이 있으면 언제든 말해주세요!

작성자: [l34p](https://github.com/L34p/)

[CVE-2014-6277]: https://en.wikipedia.org/wiki/Shellshock_(software_bug)#CVE-2014-6277
[shellshock]: https://en.wikipedia.org/wiki/Shellshock_(software_bug)
