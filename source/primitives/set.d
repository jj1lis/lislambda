module primitives.set;

import std.range.primitives : ElementType, isInputRange;
import std.container.rbtree;
//import std.traits : ConstOf;
import std.traits : isImplicitlyConvertible;

/**
This is the implements of Set using a red-black tree (std.container.rbtree).

License: $(HTTP opensource.org/licenses/mit-license.php, The MIT License)

Author: $(HTTP twitter.com/home, jj1lis)

Source: $(HTTP github.com/jj1lis/lislambda/blob/master/source/primitive/set.d, source/primitive/set.d)

*/


/**
  * Implementation of a set.
  * Set!Elem holds values of type Elem as elements.
  */
class Set(Elem, alias less = "a < b", bool allowDuplicates = false){
    private:
        RedBlackTree!(Elem, less, allowDuplicates) tree;

        template isImplicitlyConvertibleToElem(T){
            alias isImplicitlyConvertibleToElem = isImplicitlyConvertible!(T, Elem) ;
        }

    public:

        /// Returns whether the set is empty or not.
        @property bool empty() const {
            return tree.empty;
        }

        /**
          * Returns length of the set.
          * Internally, this returns the size of rbtree.
          */
        @property size_t length() const {
            return tree.length;
        }

        /**
          * Returns elements of the set.
          * The type of return value is `Elem[]`.
          */
        @property auto elements() const {
            import std.array : array;
            return tree[].array;
        }

        /**
          * Returns whether `e` is included in the set.
          * This internally uses the property `in` of rbtree.
          */
        bool opBinaryRight(string op)(Elem e) const if(op == "in"){
            return e in tree;
        }

        /// `A + B` returns a union of A and B.
        Set!(Elem, less, allowDuplicates) opBinary(string op)(Set!(Elem, less, allowDuplicates) rset) if(op == "+"){
            return new Set(this.elements ~ rset.elements);
        }

        /// `A ^ B` returns a intersection of A and B.
        Set!(Elem, less, allowDuplicates) opBinary(string op)(Set!(Elem, less, allowDuplicates) rset) if(op == "^"){
            import std.algorithm : filter;

            return new Set(this.elements.filter!(e => e in rset));
        }

        /// `A - B` returns a set difference that removed elements of B from A.
        Set!(Elem, less, allowDuplicates) opBinary(string op)(Set!(Elem, less, allowDuplicates) rset) if(op == "-"){
            auto diff = this.tree.dup;
            diff.removeKey(rset.elements);
            return new Set(diff[]);
        }

        /// Inserts elements to the set.
        void insert(T)(T e) if(isImplicitlyConvertibleToElem!T){
            version(none){
                import std.stdio;
                writefln("->insert %s", e);
            }

            this.tree.insert(e);
        }

        /++ Ditto +/
        void insert(R)(R range) if(isImplicitlyConvertibleToElem!(ElementType!R) && isInputRange!R){
            version(none){
                import std.stdio;
                writefln("insert %s", range);
            }

            import std.algorithm : each;

            range.each!(e => this.insert(e));
        }

        /// removes element from the set.
        void remove(Elems...)(Elems elems) if(allSatisfy!(isImplicitlyConvertibleToElem!Elems, Elems)){
            this.tree.removeKey(elems);
        }

        /++ Ditto +/
        void remove(ElemArray)(scope ElemArray[] elems) if(isImplicitlyConvertibleToElem!ElemArray){
            this.tree.removeKey(elems);
        }

        /++ Ditto +/
        void remove(R)(R range) if(isImplicitlyConvertibleToElem!(ElementType!R) && isInputRange!R && !isDynamicRange!R){
            this.tree.removeKey(range);
        }

        this(){
            tree = redBlackTree!Elem();
        }

        this(R)(R range) if(isImplicitlyConvertibleToElem!(ElementType!R) && isInputRange!R){
            tree = redBlackTree!Elem();

            version(none){
                import std;
                writefln("init tree: %s", this.elements);
                writefln("range: %s", range);
            }

            this.insert(range);

            version(none){
                import std;
                writefln("tree status: %s", this.elements);
            }
        }

        version(unittest) @property gettree(){
            return tree;
        }
}


/// Creates new Set!T with no elements.
auto set(T)(){
    return new Set!T();
}

/// Creates new Set!T with some elements.
auto set(T, R)(R range) if(isImplicitlyConvertible!(ElementType!R, T) && isInputRange!R){
    return new Set!T(range);
}

@trusted unittest{
    import std;

    writeln("unittest start.");

    auto set1 = set!int([0, 1, 2, 3, 4]);
    auto set2 = set!int([5, 6, 7, 8, 9]);
    auto even = set!int([0, 2, 4, 6, 8]);
    writefln("addr set1 = %s", &set1);
    writefln("addr set2 = %s", &set2);
    writefln("addr even = %s", &even);

    writefln("set1 = %s", set1.elements);
    writefln("set2 = %s", set2.elements);
    writefln("even = %s", even.elements);
    writefln("set1 + set2 = %s", (set1 + set2).elements);
    writefln("set1 - set2 = %s", (set1 - set2).elements);
    writefln("set1 - even = %s", (set1 - even).elements);
    writefln("set2 - even = %s", (set2 - even).elements);
    writefln("set1 = %s", set1.elements);
    writefln("set2 = %s", set2.elements);
    writefln("even = %s", even.elements);
    writefln("set1 ^ set2 = %s", (set1 ^ set2).elements);
    writefln("set1 ^ even = %s", (set1 ^ even).elements);
    writefln("set2 ^ even = %s", (set2 ^ even).elements);

    //typeof(set1.elements).stringof.writeln;

    auto emp = set!int;
    emp.elements.writeln;
}
