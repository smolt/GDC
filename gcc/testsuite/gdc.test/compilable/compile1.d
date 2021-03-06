// PERMUTE_ARGS:

/**************************************************
    1748 class template with stringof
**************************************************/

struct S1748(T) {}
static assert(S1748!int.stringof == "S1748!int");

class C1748(T) {}
static assert(C1748!int.stringof == "C1748!int");

/**************************************************
    5996    ICE(expression.c)
**************************************************/

template T5996(T)
{
    auto bug5996() {
        if (anyOldGarbage) {}
        return 2;
    }
}
static assert(!is(typeof(T5996!(int).bug5996())));

/**************************************************
    8532    segfault(mtype.c) - type inference + pure
**************************************************/
auto segfault8532(Y, R ...)(R r, Y val) pure
{ return segfault8532(r, val); }

static assert(!is(typeof( segfault8532(1,2,3))));

/**************************************************
    8982    ICE(ctfeexpr.c) __parameters with error in default value
**************************************************/
template ice8982(T)
{
    void bug8982(ref const int v = 7){}

    static if (is(typeof(bug8982) P == __parameters)) {
        pragma(msg, ((P[0..1] g) => g[0])());
    }
}

static assert(!is(ice8982!(int)));


/**************************************************
    8801    ICE assigning to __ctfe
**************************************************/
static assert(!is(typeof( { bool __ctfe= true; })));
static assert(!is(typeof( { __ctfe |= true; })));

/**************************************************
    5932    ICE(s2ir.c)
    6675    ICE(glue.c)
**************************************************/

void bug3932(T)() {
    static assert( 0 );
    func5932( 7 );
}

void func5932(T)( T val ) {
    void onStandardMsg() {
        foreach( t; T ) { }
    }
}

static assert(!is(typeof(
    {
        bug3932!(int)();
    }()
)));

/**************************************************
    6650    ICE(glue.c) or wrong-code
**************************************************/

auto bug6650(X)(X y)
{
    X q;
    q = "abc";
    return y;
}

static assert(!is(typeof(bug6650!(int)(6))));
static assert(!is(typeof(bug6650!(int)(18))));

/**************************************************
  6661 Templates instantiated only through is(typeof()) shouldn't cause errors
**************************************************/

template bug6661(Q)
{
    int qutz(Q y)
    {
        Q q = "abc";
        return 67;
    }
    static assert(qutz(13).sizeof!=299);
    const Q blaz = 6;
}

static assert(!is(typeof(bug6661!(int).blaz)));

template bug6661x(Q)
{
    int qutz(Q y)
    {
        Q q = "abc";
        return 67;
    }
}
// should pass, but doesn't in current
//static assert(!is(typeof(bug6661x!(int))));

/**************************************************
    6599    ICE(constfold.c) or segfault
**************************************************/

string bug6599extraTest(string x) { return x ~ "abc"; }

template Bug6599(X)
{
    class Orbit
    {
        Repository repository = Repository();
    }

    struct Repository
    {
        string fileProtocol = "file://";
        string blah = bug6599extraTest("abc");
        string source = fileProtocol ~ "/usr/local/orbit/repository";
    }
}

static assert(!is(typeof(Bug6599!int)));

/**************************************************
    8422    TypeTuple of tuples can't be read at compile time
**************************************************/

template TypeTuple8422(TList...)
{
    alias TList TypeTuple8422;
}

struct S8422 { int x; }

void test8422()
{
    enum a = S8422(1);
    enum b = S8422(2);
    enum c = [1,2,3];
    foreach(t; TypeTuple8422!(b, a)) {
        enum u = t;
    }
    foreach(t; TypeTuple8422!(c)) {
        enum v = t;
    }
}

/**************************************************
    6096    ICE(el.c) with -O
**************************************************/

cdouble c6096;

int bug6096()
{
    if (c6096) return 0;
    return 1;
}

/**************************************************
    7681  Segfault
**************************************************/

static assert( !is(typeof( (){
      undefined ~= delegate(){}; return 7;
  }())));

/**************************************************
    8639  Buffer overflow
**************************************************/

void t8639(alias a)() {}
void bug8639() {
  t8639!({auto r = -real.max;})();
}

/**************************************************
    7751  Segfault
**************************************************/

static assert( !is(typeof( (){
    bar[]r; r ~= [];
     return 7;
  }())));

/**************************************************
    7639  Segfault
**************************************************/

static assert( !is(typeof( (){
    enum foo =
    [
        str : "functions",
    ];
})));

/**************************************************
    11991
**************************************************/

void main()
{
    int Throwable;
    int object;
    try
    {
    }
    catch
    {
    }
}

/**************************************************
    11939
**************************************************/

void test11939()
{
    scope(failure)
    {
        import object : Object;
    }
    throw new Exception("");
}

/**************************************************
    5796
**************************************************/

template A(B) {
    pragma(msg, "missing ;")
    enum X = 0;
}

static assert(!is(typeof(A!(int))));

/**************************************************
    6720
**************************************************/
void bug6720() { }

static assert(!is(typeof(
cast(bool)bug6720()
)));

/**************************************************
    1099
**************************************************/

template Mix1099(int a) {
   alias typeof(this) ThisType;
    static assert (ThisType.init.tupleof.length == 2);
}


struct Foo1099 {
    mixin Mix1099!(0);
    int foo;
    mixin Mix1099!(1);
    int bar;
    mixin Mix1099!(2);
}

/**************************************************
    8788 - super() and return
**************************************************/

class B8788 {
        this ( ) { }
}

class C8788(int test) : B8788
{
    this ( int y )
    {   // TESTS WHICH SHOULD PASS
        static if (test == 1) {
            if (y == 3) {
                super();
                return;
            }
            super();
            return;
        } else static if (test == 2) {
            if (y == 3) {
                super();
                return;
            }
            super();
        } else static if (test == 3) {
            if (y > 3) {
                if (y == 7) {
                   super();
                   return;
                }
                super();
                return;
            }
            super();
        } else static if (test == 4) {
            if (y > 3) {
                if (y == 7) {
                   super();
                   return;
                }
                else if (y> 5)
                    super();
                else super();
                return;
            }
            super();
        }
        // TESTS WHICH SHOULD FAIL
        else static if (test == 5) {
            if (y == 3) {
                super();
                return;
            }
            return; // no super
        } else static if (test == 6) {
            if (y > 3) {
                if (y == 7) {
                   super();
                   return;
                }
                super();
            }
            super(); // two calls
        } else static if (test == 7) {
            if (y == 3) {
                return; // no super
            }
            super();
        } else static if (test == 8) {
            if (y > 3) {
                if (y == 7) {
                   return; // no super
                }
                super();
                return;
            }
            super();
        } else static if (test == 9) {
            if (y > 3) {
                if (y == 7) {
                   super();
                   return;
                }
                else if (y> 5)
                    super();
                else return; // no super
                return;
            }
            super();
        }
    }
}

static assert( is(typeof( { new C8788!(1)(0); } )));
static assert( is(typeof( { new C8788!(2)(0); } )));
static assert( is(typeof( { new C8788!(3)(0); } )));
static assert( is(typeof( { new C8788!(4)(0); } )));
static assert(!is(typeof( { new C8788!(5)(0); } )));
static assert(!is(typeof( { new C8788!(6)(0); } )));
static assert(!is(typeof( { new C8788!(7)(0); } )));
static assert(!is(typeof( { new C8788!(8)(0); } )));
static assert(!is(typeof( { new C8788!(9)(0); } )));

/**************************************************
    4967, 7058
**************************************************/

enum Bug7058 bug7058 = { 1.5f, 2};
static assert(bug7058.z == 99);

struct Bug7058
{
     float x = 0;
     float y = 0;
     float z = 99;
}


/***************************************************/

void test12094()
{
    auto n = null;
    int *a;
    int[int] b;
    int[] c;
    auto u = true ? null : a;
    auto v = true ? null : b;
    auto w = true ? null : c;
    auto x = true ? n : a;
    auto y = true ? n : b;
    auto z = true ? n : c;
    a = n;
    b = n;
    c = n;
}

/***************************************************/

template test8163(T...)
{
    struct Point
    {
        T fields;
    }

    enum N = 2; // N>=2 triggers the bug
    extern Point[N] bar();

    void foo()
    {
        Point[N] _ = bar();
    }
}

alias test8163!(long) _l;
alias test8163!(double) _d;
alias test8163!(float, float) _ff;
alias test8163!(int, int) _ii;
alias test8163!(int, float) _if;
alias test8163!(ushort, ushort, ushort, ushort) _SSSS;
alias test8163!(ubyte, ubyte, ubyte, ubyte, ubyte, ubyte, ubyte, ubyte) _BBBBBBBB;
alias test8163!(ubyte, ubyte, ushort, float) _BBSf;


/***************************************************/
// 4757

auto foo4757(T)(T)
{
    static struct Bar(T)
    {
        void spam()
        {
            foo4757(1);
        }
    }
    return Bar!T();
}

void test4757()
{
    foo4757(1);
}

/***************************************************/
// 9348

void test9348()
{
    @property Object F(int E)() { return null; }

    assert(F!0 !is null);
    assert(F!0 !in [new Object():1]);
}

/***************************************************/
// 9690

@disable
{
    void dep9690() {}
    void test9690()
    {
        dep9690();      // OK
        void inner()
        {
            dep9690();  // OK <- NG
        }
    }
}

/***************************************************/
// 9987

static if (is(object.ModuleInfo == struct))
{
    struct ModuleInfo {}

    static assert(!is(object.ModuleInfo == ModuleInfo));
    static assert(object.ModuleInfo.sizeof != ModuleInfo.sizeof);
}
static if (is(object.ModuleInfo == class))
{
    class ModuleInfo {}

    static assert(!is(object.ModuleInfo == ModuleInfo));
    static assert(__traits(classInstanceSize, object.ModuleInfo) !=
                  __traits(classInstanceSize, ModuleInfo));
}

/***************************************************/
// 10326

class C10326
{
    int val;
    invariant   { assert(val == 0); }
    invariant() { assert(val == 0); }
}

/***************************************************/
// 11554

enum E11554;
static assert(is(E11554 == enum));

struct Bro11554(N...) {}
static assert(!is(E11554 unused : Bro11554!M, M...));

/***************************************************/
// 12302

template isCallable12302(T...)
    if (T.length == 1)
{
    static if (is(typeof(& T[0].opCall) == delegate))
        enum bool isCallable12302 = true;
    else
    static if (is(typeof(& T[0].opCall) V : V*) && is(V == function))
        enum bool isCallable12302 = true;
    else
        enum bool isCallable12302 = true;
}

class A12302
{
    struct X {}
    X x;
    auto opDispatch(string s, TArgs...)(TArgs args)
    {
        mixin("return x."~s~"(args);");
    }
}

A12302 func12302() { return null; }
enum b12302 = isCallable12302!func12302;

/***************************************************/
// 12476

template A12476(T) {  }

struct S12476(T)
{
    alias B = A12476!T;
}

class C12476(T)
{
    alias B = A12476!T;
}

struct Bar12476(alias Foo)
{
    Foo!int baz;
    alias baz this;
}

alias Identity12476(alias A) = A;

alias sb12476 = Identity12476!(Bar12476!S12476.B);
alias cb12476 = Identity12476!(Bar12476!C12476.B);

static assert(__traits(isSame, sb12476, A12476!int));
static assert(__traits(isSame, cb12476, A12476!int));

/***************************************************/
// 12506

import imports.a12506;
private           bool[9] r12506a = f12506!(i => true)(); // OK
private immutable bool[9] r12506b = f12506!(i => true)(); // OK <- error

/***************************************************/
// 12555

class A12555(T)
{
    Undef12555 error;
}

static assert(!__traits(compiles, {
    class C : A12555!C  { }
}));

/***************************************************/
// 11622

class A11622(T)
{
    B11622!T foo()
    {
        return new B11622!T;
    }
}

class B11622(T) : T
{
}

static assert(!__traits(compiles, {
    class C : A11622!C  { }
}));

/***************************************************/
// 12688

void writeln12688(A...)(A) {}

struct S12688
{
    int foo() @property { return 1; }
}

void test12688()
{
    S12688 s;
    s.foo.writeln12688;   // ok
    (s.foo).writeln12688; // ok <- ng
}

/***************************************************/
// 12703

struct S12703
{
    this(int) {}
}

final class C12703
{
    S12703 s = S12703(1);
}
