use "pony_test"
use ".."
use "time"
use "random"
use "collections"



actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)
  new make () =>
    None
  fun tag tests(test: PonyTest) =>
    test(_TestFingerprint)
    test(_TestBitbucket)

class iso _TestFingerprint is UnitTest
  fun name(): String => "Testing Fingerprint"
  fun apply(t: TestHelper) =>
    let fpsize: USize = 4
    let fp1: Fingerprint = Fingerprint(fpsize)
    let fp2: Fingerprint = Fingerprint(fpsize)
    try
      fp1.set(0, true)?
      fp1.set(1, false)?
      fp1.set(2, false)?
      fp1.set(3, true)?
      fp2(0)? = true
      fp2(1)? = false
      fp2(2)? = false
      fp2(3)? = true
      t.assert_true(fp2 == fp1)
      fp1(0)? = false
      t.assert_true(fp2 != fp1)
      t.assert_false(fp1(0)?)
      try
        fp1.set(4, true)?
        t.fail("Index out of range")
      else
        t.log("out of range blocked")
      end
    else
      t.fail("Fingerprint Error")
    end

  class iso _TestBitbucket is UnitTest
    fun name(): String => "Testing Bitbucket"
    fun apply(t: TestHelper) =>
      let now = Time.now()
      var gen = Rand(now._1.u64(), now._2.u64())
      let fpsize: USize = 4
      let bsize: USize = 4
      let fpcount: USize = 6
      let fps: Array[Fingerprint] = Array[Fingerprint](6)
      let fp2: Fingerprint = Fingerprint(fpsize)
      let bb: Bitbucket = Bitbucket(fpsize, bsize)
      let bb2: Bitbucket = Bitbucket(fpsize, fps.size())
      try
        for i in Range(0, fpcount) do
          let fp = Fingerprint(fpsize)
          for j in Range(0, fpsize) do
            fp.set(j, (gen.u8() % 2) == 0)?
          end
          fps.push(fp)
        end
      else
        t.fail("Fingerprint Generation Error")
      end
      try
        for i in Range(0, bsize) do
          bb(i)? = fps(i)?
        end
      else
        t.fail("Bitbucket Assignment Error")
      end
      try
        for i in Range(0, bsize) do
          t.log(i.string())
          t.assert_true(bb(i)? == fps(i)?)
        end
      else
        t.fail("Bitbucket Fingerprint Error")
      end
      try
        for i in Range(0, bsize) do
          t.assert_true(bb.contains(fps(i)?)?)
        end
      else
        t.fail("Bitbucket Containment Error")
      end
      try
        for i in Range(bsize, fps.size()) do
          bb.push(fps(i)?)?
        end
      else
        t.fail("Bitbucket Push Error")
      end
      try
        for i in Range(bsize, fps.size()) do
          t.assert_true(bb.contains(fps(i)?)?)
        end
      else
        t.fail("Bitbucket Containment Error")
      end
      try
        for fp in fps.values() do
          bb2.push(fp)?
          t.assert_true(bb2(bb2.size() - 1)? == fp)
        end
      else
        t.fail("Bitbucket Push Error")
      end

      try
        for i in Range(0, fps.size()) do
          t.log(i.string())
          t.assert_true(bb2(i)? == fps(i)?)
        end
      else
        t.fail("Bitbucket Fingerprint Error")
      end

      try
        for i in Range(0, fps.size()) do
          t.log(i.string())
          t.assert_true(bb(i)? == fps(i)?)
        end
      else
        t.fail("Bitbucket Fingerprint Error")
      end
