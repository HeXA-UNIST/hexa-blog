title: 동아리 활동 내역서 자동 생성 사이트
date: 2015-02-27 21:15:00
tags:
- web
- development
---
많은 양의 활동보고서를 일일히 수정해서 쓰는 것에 불편함을 느껴, 날짜/활동내용/참가자 명단 등을 입력하면 자동으로 보고서를 만들어주는 사이트를 만들었습니다.

<p align="center"> <img src="/img/club-auto-system1.png" style="width: 70%;"/> </p>

먼저, 다음과 같이 내용을 작성하고 사진을 업로드 합니다.
그 후 Upload 버튼을 누르면,

<p align="center"> <img src="/img/club-auto-system2.png" style="width: 60%;"/> </p>

위 사진처럼 파일을 다운받을 수 있게 됩니다.

<p align="center"> <img src="/img/club-auto-system3.png" style="width: 60%;"/> </p>

위에 적었던 내용들이 다음과 같이 폼에 들어가 작성되며, 사진 또한 크기에 맞춰서 들어갑니다.

<p align="center"> <img src="/img/club-auto-system4.png" style="width: 60%;"/> </p>

출결 여부를 체크하지 않은 사람은 불참으로 기록되며, 출석 인원에서 제외됩니다.
파이썬으로 작성했으며, Flask를 사용했습니다.

[code](https://github.com/fresh-mango-tree/Activity-Report-Factory)

작성자: [fresh-mango-tree](http://freshmangotree.tistory.com/)
