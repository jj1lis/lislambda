import std;

void main(){
    int[] arr = [0, 1, 2, 3, 4];
    auto range = arr.filter!(i => i % 2 == 0);
    writefln("%s : %s", arr, typeof(arr).stringof);
    writefln("%s : %s", range, typeof(range).stringof);

    writefln("ElementType: %s, isInputRange : %s", is(ElementType!(typeof(range)) == int), isInputRange!(typeof(range)));

    auto tree = redBlackTree(arr);
    auto treearr = tree[];
    writefln("%s : %s", treearr, typeof(treearr).stringof);
    writefln("%s", typeof(treearr.array).stringof);
}
