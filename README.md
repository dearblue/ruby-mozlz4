# mozlz4 - mozlz4 archive library and tool for ruby

***ATTENTION: If you are dealing with important files, make a backup before doing so.***  
NOTE: The document is written in Japanese.

***注意: 大事なファイルを扱う場合は、バックアップを取ってから行って下さい。***

Mozilla Firefox で使われている ".mozlz4" データを格納・展開するためのライブラリ、及びコマンドラインプログラムです。


## できること

  - `mozlz4` ライブラリ (`require "mozlz4"`)
      - `MozLZ4.binread(path) -> bin`
      - `MozLZ4.binwrite(path, data) -> nil`
      - `MozLZ4.decode(src, dest) -> dest`
      - `MozLZ4.decode(src, destmax = nil, dest = nil) -> dest || string`
      - `MozLZ4.encode(src, dest) -> dest`
      - `MozLZ4.encode(src, destmax = nil, dest = nil) -> dest || string`
      - リファインメント (`using MozLZ4`)
          - `String#unmozlz4(src, dest) -> dest`
          - `String#unmozlz4(src, destmax = nil, dest = nil) -> dest || string`
          - `String#to_mozlz4(src, dest) -> dest`
          - `String#to_mozlz4(src, destmax = nil, dest = nil) -> dest || string`
  - コマンドラインプログラム
      - `jsonlz4cat` - `.mozlz4` (`.jsonlz4`) ファイルを伸長し、JSON データを `JSON.pretty_generate` して表示します。
      - `mozlz4` - 任意のファイルを `.mozlz4` ファイルとして圧縮します (gzip のように振る舞います)。
      - `mozlz4cat` - `.mozlz4` (`.jsonlz4`) ファイルを伸長し、標準出力へ出力します (gzcat のように振る舞います)。
      - `unmozlz4` - `.mozlz4` (`.jsonlz4`) ファイルを伸長します (gunzip のように振る舞います)。

    これらは初期動作が異なるだけで、中身が同じです (gzip のように)。


## 諸元

  - Product name: mozlz4
  - Version: 0.1
  - Product quality: PROTOTYPE
  - Author: [dearblue](https://github.com/dearblue)
  - Project page: <https://github.com/dearblue/ruby-mozlz4>
  - Licensing: [2 clause BSD License](LICENSE)
  - Dependency external gems:
      - [tty-pager](https://rubygems.org/gems/tty-pager)
        under [MIT License](https://github.com/piotrmurach/tty-pager/blob/master/LICENSE.txt)
        by [Piotr Murach](https://github.com/piotrmurach)
      - [extlz4](https://rubygems.org/gems/extlz4)
        under [2 clause BSD License](https://github.com/dearblue/ruby-extlz4/blob/master/LICENSE)
        by me ([dearblue](https://github.com/dearblue))
