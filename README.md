# 4d-plugin-jagger
形態素解析器

## aknowlegements

* http://www.tkl.iis.u-tokyo.ac.jp/~ynaga/jagger/index.ja.html

## 変更箇所

* `stdin` `stdout`を`dup2`でリダイレクト
* Windows対応
  * `mmap`
  * `munmap`
  * `open`
  * `lseek`
