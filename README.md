# 4d-plugin-jagger
形態素解析器

## aknowlegements

* http://www.tkl.iis.u-tokyo.ac.jp/~ynaga/jagger/index.ja.html

## 変更箇所

* `stdin`を`dup2`で代用
* `stdout`を`std::ostringstream`で代用
* Windows対応
  * `mmap`
  * `munmap`
  * `open`
  * `lseek`
