use "Bitset"
use "collections"


class Bitbucket
  let _fpSize: USize
  var _size: USize
  var _data: Bitset

  new create(fingerprintSize: USize, size': USize) =>
    _fpSize = fingerprintSize
    _size = size'
    let bits = (fingerprintSize * _size) + _size
    var bytes = bits/ 8
    if (bits % 8) > 0 then
      bytes = bytes + 1
    end
    _data = Bitset(bytes)

  fun size(): USize =>
    _size
  fun ref update(index: USize, value: Fingerprint box) ? =>
    if index >= _size then
      error
    end
    _data(index)? = true
    for i in Range(0, _fpSize) do
      _data.set(((index * _fpSize) + _size) + i, value(i)?)?
    end

  fun ref delete(index: USize) ? =>
    if index >= _size then
      error
    end
    if not _data(index)? then
      error
    end
    _data(index)? = false
    for i in Range(0, _fpSize) do
      _data.set(((index * _fpSize) + _size) + i, false)?
    end


  fun apply(index: USize): Fingerprint iso^ ? =>
    if index >= _size then
      error
    end
    if not _data(index)? then
      error
    end
    let value: Fingerprint iso = recover Fingerprint(_fpSize) end
    for i in Range(0, _fpSize) do
      value(i)? = _data(((index * _fpSize) + _size) + i)?
    end
    consume value

  fun contains(value: Fingerprint box): Bool ? =>
    for index in Range(0, _size) do
      if _data(index)? then
        var found = true
        for i in Range(0, _fpSize) do
          if value(i)? != _data(((index * _fpSize) + _size) + i)? then
            found = false
            break
          end
        end
        if found then
          return true
        end
      else
        continue
      end
    end
    false

  fun full(): Bool ? =>
    if _size == 0 then
      return true
    end
    var full' = true
    for index in Range(0, _size) do
      if  not _data(index)? then
        full' = false
        break
      end
    end
    full'


  fun ref push(value: Fingerprint box)? =>
    if full()? or (_data(_size.max(1) - 1)?) then
      let size' = _size + 1
      let bits = (_fpSize * size') + size'
      var bytes = bits / 8
      if (bits % 8) > 0 then
        bytes = bytes + 1
      end
      let data = Bitset(bytes)
      for i in Range(0, _size) do
        data.set(i, _data(i)?)?
      end

      for index in Range(0, _size) do
        for bit in Range(0, _fpSize) do
          data.set((((index * _fpSize) + size') + bit),_data(((index * _fpSize) + _size) + bit)?)?
        end
      end

      data.set(_size, true)?
      for k in Range(0, _fpSize) do
        data.set(((_size * _fpSize) + size') + k, value(k)?)?
      end

      _data = data
      _size = size'
    else
      var freeIndex = _size
      while (freeIndex >= 0) do
        if _data(freeIndex)? then
          freeIndex = freeIndex - 1
        else
          break
        end
      end
      if (freeIndex == 0) and _data(freeIndex)? then
        error
      end
      _data.set(freeIndex, true)?
      for i in Range(0, _fpSize) do
        _data.set(((freeIndex * _fpSize) + _size) + i, value(i)?)?
      end
    end
