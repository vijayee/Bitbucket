use "Bitset"
use "collections"

class Fingerprint
  let _data: Bitset
  let _size: USize

  new create(size: USize)=>
    _size = size
    var bytes = _size / 8
    if (_size % 8) > 0 then
      bytes = bytes + 1
    end
    _data = Bitset(bytes)

  fun apply(index: USize): Bool ? =>
    if index >= _size then
      error
    end
    _data(index)?

  fun ref update(index: USize, value: Bool): Bool ? =>
    if index >= _size then
      error
    end
    _data(index)? = value

  fun box eq(that: box->Fingerprint): Bool =>
    _data == that._data

  fun box ne(that: box->Fingerprint): Bool =>
    _data != that._data

  fun ref set(index: USize, value: Bool) ? =>
    if index >= _size then
      error
    end
    _data.set(index, value)?

  fun string(): String^ ? =>
    let str: String iso = recover String(_size) end
    for i in Range(0,_size) do
      str.push(if _data(i)? then 49 else 48 end)
    end
    consume str
