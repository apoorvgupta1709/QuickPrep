import '../models/question_model.dart';
import '../models/category_model.dart';

class SeedData {
  static List<Category> get categories => [
        Category(
          id: 'dsa',
          name: 'Data Structures & Algo',
          icon: 'account_tree',
          description: 'Arrays, Trees, Graphs, DP & Algorithmic complexity',
          questionCount: 6,
        ),
        Category(
          id: 'flutter_dart',
          name: 'Flutter & Dart',
          icon: 'flutter_dash',
          description: 'Widgets, State Lifecycle, Isolates & Event Loop',
          questionCount: 6,
        ),
        Category(
          id: 'python',
          name: 'Python Core',
          icon: 'terminal',
          description: 'GIL, Generators, Decorators & Memory Internals',
          questionCount: 5,
        ),
        Category(
          id: 'system_design',
          name: 'System Design',
          icon: 'dns',
          description: 'Scalability, Caching, CAP Theorem & Sharding',
          questionCount: 5,
        ),
        Category(
          id: 'sql_db',
          name: 'SQL & Databases',
          icon: 'storage',
          description: 'Indexes, ACID, B-Trees & Query Optimization',
          questionCount: 5,
        ),
        Category(
          id: 'java_oop',
          name: 'Java & OOP',
          icon: 'coffee',
          description: 'JVM, Garbage Collection, Threads & Design Patterns',
          questionCount: 5,
        ),
      ];

  static List<Question> get questions => [
        // ================= DSA =================
        Question(
          id: 'dsa_1',
          categoryId: 'dsa',
          categoryName: 'Data Structures & Algo',
          question: 'What is the time complexity difference between Array Search and Hash Table Lookup?',
          answer: 'Unsorted Array linear search is O(n). A Hash Table provides average O(1) time complexity using hash buckets, though worst-case is O(n) during severe hash collisions.',
          codeSnippet: '''// Hash Map Lookup O(1) Average
final map = {'twoSum': 15, 'target': 9};
if (map.containsKey('target')) {
  print(map['target']);
}''',
          language: 'dart',
          companyTags: ['FAANG', 'FinTech', 'Startup'],
          difficulty: 'Easy',
          deepDiveExplanation: 'Hash maps compute an index via hashing h(k) % table_size. Good collision resolution (separate chaining with red-black trees in Java 8+ or open addressing) ensures O(1) amortized performance.',
          quizOptions: [
            'Array O(1), Hash Table O(n)',
            'Array O(n), Hash Table O(1) average',
            'Both are always O(log n)',
            'Both are always O(n)'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'dsa_2',
          categoryId: 'dsa',
          categoryName: 'Data Structures & Algo',
          question: 'How does Binary Search achieve O(log n) complexity?',
          answer: 'Binary Search repeatedly divides a sorted search interval in half. By comparing the target with the median element, it eliminates half the remaining search space in each iteration.',
          codeSnippet: '''def binary_search(arr, target):
    low, high = 0, len(arr) - 1
    while low <= high:
        mid = (low + high) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            low = mid + 1
        else:
            high = mid - 1
    return -1''',
          language: 'python',
          companyTags: ['FAANG', 'MNC', 'FinTech'],
          difficulty: 'Medium',
          deepDiveExplanation: 'For n elements, n / 2^k = 1 implies k = log2(n) steps. Requires random access indexing (arrays), so linked lists cannot perform binary search in O(log n).',
          quizOptions: [
            'By checking all elements in reverse order',
            'By halving the search space each step on a sorted array',
            'By using hash buckets to find items',
            'By traversing a binary tree in pre-order'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'dsa_3',
          categoryId: 'dsa',
          categoryName: 'Data Structures & Algo',
          question: 'What is the core distinction between BFS and DFS traversal on graphs?',
          answer: 'BFS explores graph neighbor-by-neighbor using a Queue (FIFO), finding the shortest path in unweighted graphs. DFS explores as deep as possible along each branch using a Stack or Recursion (LIFO).',
          codeSnippet: '''// BFS uses Queue; DFS uses Stack/Recursion
Queue<int> queue = Queue()..add(startNode);
visited.add(startNode);
while (queue.isNotEmpty) {
  int node = queue.removeFirst();
  for (int neighbor in adj[node]!) {
    if (!visited.contains(neighbor)) {
      visited.add(neighbor);
      queue.add(neighbor);
    }
  }
}''',
          language: 'dart',
          companyTags: ['FAANG', 'Startup'],
          difficulty: 'Medium',
          deepDiveExplanation: 'BFS space complexity is O(w) where w is max width. DFS space complexity is O(h) where h is max depth. Use BFS for shortest path and DFS for topological sort or cycle detection.',
          quizOptions: [
            'BFS uses Stack, DFS uses Queue',
            'BFS uses Queue (FIFO), DFS uses Stack/Recursion (LIFO)',
            'BFS is O(V^2), DFS is O(V)',
            'There is no functional difference'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'dsa_4',
          categoryId: 'dsa',
          categoryName: 'Data Structures & Algo',
          question: 'What characterizes Dynamic Programming problems?',
          answer: 'Dynamic Programming applies to problems exhibiting Overlapping Subproblems and Optimal Substructure. It stores subproblem results via Memoization (top-down) or Tabulation (bottom-up) to eliminate redundant work.',
          codeSnippet: '''// DP: Fibonacci with Memoization O(n)
int fib(int n, Map<int, int> memo) {
  if (n <= 1) return n;
  if (!memo.containsKey(n)) {
    memo[n] = fib(n - 1, memo) + fib(n - 2, memo);
  }
  return memo[n]!;
}''',
          language: 'dart',
          companyTags: ['FAANG', 'FinTech'],
          difficulty: 'Hard',
          deepDiveExplanation: 'Optimal substructure means optimal solution of the problem contains optimal solutions of subproblems. Without overlapping subproblems, Divide & Conquer (e.g. MergeSort) is used instead.',
          quizOptions: [
            'Greedy choice property only',
            'Overlapping subproblems & Optimal substructure',
            'Randomized pivot selection',
            'Linear equations only'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'dsa_5',
          categoryId: 'dsa',
          categoryName: 'Data Structures & Algo',
          question: 'What is QuickSort average vs worst-case time complexity, and how is worst-case prevented?',
          answer: 'Average time complexity is O(n log n). Worst-case is O(n^2) when poor pivots are chosen (e.g., sorted array with first element as pivot). Prevented using randomized pivot selection or median-of-three.',
          codeSnippet: '''// Randomized QuickSort Pivot Selection
int pivotIndex = low + Random().nextInt(high - low + 1);
swap(arr, pivotIndex, high);''',
          language: 'dart',
          companyTags: ['FAANG', 'MNC', 'FinTech'],
          difficulty: 'Medium',
          deepDiveExplanation: 'QuickSort is an in-place, cache-friendly unstable sorting algorithm. Dual-pivot QuickSort (Yaroslavskiy algorithm) is Java standard library\'s default for primitives.',
          quizOptions: [
            'Avg: O(n), Worst: O(n log n)',
            'Avg: O(n log n), Worst: O(n^2)',
            'Avg: O(n^2), Worst: O(n^3)',
            'Avg: O(log n), Worst: O(n)'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'dsa_6',
          categoryId: 'dsa',
          categoryName: 'Data Structures & Algo',
          question: 'How does an LRU (Least Recently Used) Cache achieve O(1) get and put operations?',
          answer: 'By pairing a Hash Map (for O(1) node lookup) with a Doubly Linked List (for O(1) removal, head insertion, and tail eviction of oldest items).',
          codeSnippet: '''class LRUCache:
    def __init__(self, capacity: int):
        self.cap = capacity
        self.map = {} # key -> Node
        self.head = Node(0, 0) # Dummy Head (Most Recent)
        self.tail = Node(0, 0) # Dummy Tail (Least Recent)
        self.head.next = self.tail
        self.tail.prev = self.head''',
          language: 'python',
          companyTags: ['FAANG', 'FinTech', 'Startup'],
          difficulty: 'Hard',
          deepDiveExplanation: 'Every get(key) detaches the node and moves it to the head. When size exceeds capacity on put(key, val), the node before the tail dummy is evicted in O(1).',
          quizOptions: [
            'Using Binary Search Tree and Array',
            'Using Hash Map + Doubly Linked List',
            'Using Single Queue with linear scan',
            'Using Min-Heap only'
          ],
          correctOptionIndex: 1,
        ),

        // ================= FLUTTER & DART =================
        Question(
          id: 'flt_1',
          categoryId: 'flutter_dart',
          categoryName: 'Flutter & Dart',
          question: 'What is the role of the Dart Event Loop and Microtask Queue?',
          answer: 'Dart runs on a single thread. The Event Loop processes events from two queues: Microtask Queue (high priority, e.g., scheduleMicrotask) and Event Queue (I/O, timers, user taps, Futures). Microtasks drain completely before the next event runs.',
          codeSnippet: '''print('1');
scheduleMicrotask(() => print('2 - microtask'));
Future(() => print('3 - event queue'));
print('4');
// Output: 1, 4, 2 - microtask, 3 - event queue''',
          language: 'dart',
          companyTags: ['FAANG', 'MNC', 'Startup'],
          difficulty: 'Medium',
          deepDiveExplanation: 'Because the microtask queue has strict priority over the event queue, scheduling too many microtasks will starve the event loop and freeze UI frame rendering.',
          quizOptions: [
            'Event queue executes before microtasks',
            'Microtask queue executes before event queue items',
            'Both execute on separate CPU threads simultaneously',
            'Dart does not use an event loop'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'flt_2',
          categoryId: 'flutter_dart',
          categoryName: 'Flutter & Dart',
          question: 'Explain the three trees in Flutter: Widget, Element, and RenderObject.',
          answer: 'Widgets are lightweight immutable configurations. Elements are the persistent lifecycle nodes managing state and tree identity. RenderObjects handle painting, layout measurements, and hit testing.',
          codeSnippet: '''// Widget (Config) -> Element (Lifecycle) -> RenderObject (Paint/Layout)
class MyBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(color: Colors.blue);
}''',
          language: 'dart',
          companyTags: ['FAANG', 'FinTech', 'Startup'],
          difficulty: 'Hard',
          deepDiveExplanation: 'When build() returns a new Widget instance, Flutter compares Widget.canUpdate(oldWidget, newWidget) via runtimeType and key. If true, the existing Element updates its reference and avoids rebuilding the expensive RenderObject.',
          quizOptions: [
            'Widgets handle layout, RenderObjects handle config',
            'Widget is config, Element manages lifecycle, RenderObject paints/layouts',
            'All three trees are discarded every frame',
            'Flutter only has one unified tree'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'flt_3',
          categoryId: 'flutter_dart',
          categoryName: 'Flutter & Dart',
          question: 'What is a Dart Isolate and when should you use one?',
          answer: 'An Isolate is Dart\'s concurrent execution unit with its own private heap memory and event loop. They do not share memory; they communicate solely via message passing (SendPort/ReceivePort). Use Isolates for heavy CPU tasks like JSON parsing large payloads or image processing.',
          codeSnippet: '''// Running expensive calculation off the UI thread
final result = await Isolate.run(() {
  return heavyMatrixComputation();
});''',
          language: 'dart',
          companyTags: ['FAANG', 'MNC', 'Startup'],
          difficulty: 'Medium',
          deepDiveExplanation: 'Since Isolates have separate heaps, there is no shared memory locking or mutex deadlocks. In Dart 2.19+, Isolate.run simplifies short-lived worker tasks by handling port creation and teardown automatically.',
          quizOptions: [
            'A thread that shares the main heap memory',
            'An isolated execution thread with independent heap memory and message passing',
            'A background HTTP client service',
            'A Flutter widget lifecycle hook'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'flt_4',
          categoryId: 'flutter_dart',
          categoryName: 'Flutter & Dart',
          question: 'Why should you use "const" constructors whenever possible in Flutter?',
          answer: 'Const constructors create compile-time canonicalized instances. Flutter\'s reconciliation skips rebuilding const widget subtrees during setState calls, preserving CPU cycles and maintaining 60/120 FPS.',
          codeSnippet: '''// Rebuilt on every parent setState:
Widget bad = Padding(padding: EdgeInsets.all(8.0), child: Text('Hi'));

// Reused canonical instance; zero rebuild overhead:
const Widget good = Padding(padding: EdgeInsets.all(8.0), child: Text('Hi'));''',
          language: 'dart',
          companyTags: ['FAANG', 'MNC'],
          difficulty: 'Easy',
          deepDiveExplanation: 'Compile-time constants reside in read-only memory and share exact identity across identical invocations (identical(const Text("a"), const Text("a")) == true).',
          quizOptions: [
            'To make variables mutable at runtime',
            'To enable compile-time instance reuse and prevent unnecessary subtree rebuilds',
            'To force asynchronous execution',
            'Const widgets cannot have child widgets'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'flt_5',
          categoryId: 'flutter_dart',
          categoryName: 'Flutter & Dart',
          question: 'What is the purpose of BuildContext in Flutter?',
          answer: 'BuildContext is a handle to the location of a widget in the widget tree. It provides access to InheritedWidgets (Theme, MediaQuery, Navigator) and defines the element hierarchy.',
          codeSnippet: '''// Looking up inherited theme from the widget tree
final theme = Theme.of(context);
final screenWidth = MediaQuery.of(context).size.width;''',
          language: 'dart',
          companyTags: ['MNC', 'Startup'],
          difficulty: 'Easy',
          deepDiveExplanation: 'BuildContext is actually the Element associated with the Widget. Methods like dependOnInheritedWidgetOfExactType register the element as a subscriber for rebuilds when inherited data changes.',
          quizOptions: [
            'A global application singleton',
            'A reference to the widget\'s position in the Element tree',
            'The native Android Activity instance',
            'A thread identifier'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'flt_6',
          categoryId: 'flutter_dart',
          categoryName: 'Flutter & Dart',
          question: 'What is the lifecycle sequence of a StatefulWidget in Flutter?',
          answer: 'createState() -> initState() -> didChangeDependencies() -> build() -> didUpdateWidget() -> deactivate() -> dispose().',
          codeSnippet: '''@override
void initState() {
  super.initState();
  // One-time initialization; context not fully ready for inherited widgets
}

@override
void dispose() {
  _controller.dispose(); // Cleanup controllers & streams
  super.dispose();
}''',
          language: 'dart',
          companyTags: ['FAANG', 'MNC', 'FinTech'],
          difficulty: 'Medium',
          deepDiveExplanation: 'didChangeDependencies is called immediately after initState and whenever an InheritedWidget that this state subscribed to changes. dispose() is where animation controllers, text editing controllers, and streams must be closed to avoid memory leaks.',
          quizOptions: [
            'build -> initState -> dispose',
            'initState -> didChangeDependencies -> build -> dispose',
            'initState -> build -> deactivate -> initState',
            'createState -> dispose -> build'
          ],
          correctOptionIndex: 1,
        ),

        // ================= PYTHON CORE =================
        Question(
          id: 'py_1',
          categoryId: 'python',
          categoryName: 'Python Core',
          question: 'What is the Python Global Interpreter Lock (GIL)?',
          answer: 'The GIL is a mutex that prevents multiple native threads from executing Python bytecodes simultaneously in CPython. It ensures thread safety for CPython\'s reference counting memory management.',
          codeSnippet: '''import threading
# CPU-bound threads in Python do NOT achieve multi-core parallelism due to the GIL
# Use multiprocessing module instead!''',
          language: 'python',
          companyTags: ['FAANG', 'FinTech'],
          difficulty: 'Hard',
          deepDiveExplanation: 'For I/O-bound tasks (network, disk), Python threads release the GIL while waiting. For CPU-bound workloads, use the multiprocessing module or process pools to leverage multiple CPU cores.',
          quizOptions: [
            'A lock preventing file writing',
            'A mutex allowing only one thread to execute Python bytecode at a time in CPython',
            'A security sandbox for untrusted code',
            'A garbage collection cycle detector'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'py_2',
          categoryId: 'python',
          categoryName: 'Python Core',
          question: 'How do Generators and the "yield" keyword work in Python?',
          answer: 'Generators yield values one at a time on demand and suspend their execution state between calls, enabling memory-efficient processing of infinite or huge datasets without loading everything into RAM.',
          codeSnippet: '''def read_large_file(file_path):
    with open(file_path, "r") as f:
        for line in f:
            yield line.strip()

# Consumes O(1) memory instead of O(N)''',
          language: 'python',
          companyTags: ['FAANG', 'MNC', 'FinTech'],
          difficulty: 'Medium',
          deepDiveExplanation: 'A generator function returns a generator iterator. Each call to next() resumes execution right after the yield statement until the next yield or StopIteration exception.',
          quizOptions: [
            'They create immutable tuples in memory',
            'They lazily generate items one at a time, keeping memory footprint O(1)',
            'They spawn asynchronous background threads',
            'They compile Python into C code'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'py_3',
          categoryId: 'python',
          categoryName: 'Python Core',
          question: 'Explain how Python decorators work and their syntax sugar.',
          answer: 'A decorator is a callable that takes a function as an argument and returns a modified or wrapped function, allowing cross-cutting concerns (logging, timing, auth) to be injected cleanly.',
          codeSnippet: '''import functools
import time

def timer(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        print(f"{func.__name__} took {time.perf_counter() - start:.4f}s")
        return result
    return wrapper

@timer
def compute():
    return sum(range(1000000))''',
          language: 'python',
          companyTags: ['FAANG', 'Startup'],
          difficulty: 'Medium',
          deepDiveExplanation: '@timer is syntactic sugar for compute = timer(compute). @functools.wraps preserves original function metadata (__name__, __doc__).',
          quizOptions: [
            'A tool to declare static types',
            'A higher-order function that wraps and extends another function without modifying its source',
            'A mechanism for multiple inheritance',
            'A garbage collector configuration'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'py_4',
          categoryId: 'python',
          categoryName: 'Python Core',
          question: 'How does Python handle memory management and garbage collection?',
          answer: 'Python uses Reference Counting as its primary mechanism. When an object\'s reference count drops to 0, it is deallocated immediately. A generational cyclic garbage collector handles circular reference leaks.',
          codeSnippet: '''import gc
import sys

a = []
print(sys.getrefcount(a)) # Count includes argument reference
gc.collect() # Force manual cyclic garbage collection''',
          language: 'python',
          companyTags: ['FAANG', 'MNC'],
          difficulty: 'Hard',
          deepDiveExplanation: 'The generational GC divides objects into 3 generations (Gen 0, 1, 2) based on survival cycles. Younger generations are collected more frequently based on allocation thresholds.',
          quizOptions: [
            'Pure Mark and Sweep exclusively',
            'Primary Reference Counting supplemented by Generational Cyclic Garbage Collector',
            'Manual malloc and free by the programmer',
            'Pure Reference Counting with no cycle detection'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'py_5',
          categoryId: 'python',
          categoryName: 'Python Core',
          question: 'What is the difference between "==" and "is" in Python?',
          answer: '"==" checks equality of value (via __eq__), whereas "is" checks object identity (whether two variables point to the exact same memory address in RAM via id()).',
          codeSnippet: '''a = [1, 2, 3]
b = [1, 2, 3]
print(a == b) # True (same values)
print(a is b) # False (different objects in memory)

x = None
print(x is None) # True (idiomatic check for singletons)''',
          language: 'python',
          companyTags: ['MNC', 'Startup'],
          difficulty: 'Easy',
          deepDiveExplanation: 'Python interns small integers (-5 to 256) and short strings, meaning identical small ints point to the same memory object, which can lead to confusion if "is" is improperly used for value comparison.',
          quizOptions: [
            'They are exact synonyms',
            '"==" compares value equality; "is" compares memory identity',
            '"is" compares value; "==" compares memory identity',
            '"is" is only for string types'
          ],
          correctOptionIndex: 1,
        ),

        // ================= SYSTEM DESIGN =================
        Question(
          id: 'sys_1',
          categoryId: 'system_design',
          categoryName: 'System Design',
          question: 'What does the CAP Theorem state for distributed systems?',
          answer: 'In a distributed data store, you can only provide two of three guarantees: Consistency (every read gets the most recent write), Availability (every non-failing node returns a response), and Partition Tolerance (system operates despite network network breaks). Since network partitions are inevitable in real networks, distributed systems must choose CP or AP.',
          codeSnippet: '''// CAP Choices:
// CP (Consistent + Partition Tolerant): MongoDB, HBase, ZooKeeper
// AP (Available + Partition Tolerant): Cassandra, DynamoDB, CouchDB''',
          language: 'dart',
          companyTags: ['FAANG', 'FinTech', 'Startup'],
          difficulty: 'Hard',
          deepDiveExplanation: 'PACELC theorem extends CAP: If there is a Partition (P), trade off Availability (A) vs Consistency (C); Else (E), trade off Latency (L) vs Consistency (C).',
          quizOptions: [
            'All systems must achieve C, A, and P simultaneously',
            'During a network partition, you must trade off Consistency or Availability',
            'Performance is prioritized over security',
            'Cloud architectures do not suffer from network partitions'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'sys_2',
          categoryId: 'system_design',
          categoryName: 'System Design',
          question: 'Compare Horizontal vs Vertical Scaling in backend architecture.',
          answer: 'Vertical scaling (scale up) adds more CPU/RAM/SSD to a single server. Horizontal scaling (scale out) adds more server nodes behind a load balancer, providing virtually unlimited elasticity and fault tolerance.',
          codeSnippet: '''// Horizontal Architecture:
Client -> Load Balancer (Nginx/ALB) -> [Server 1, Server 2, Server N] -> DB Cluster''',
          language: 'dart',
          companyTags: ['FAANG', 'MNC', 'Startup'],
          difficulty: 'Easy',
          deepDiveExplanation: 'Vertical scaling hits hard hardware limits and introduces single points of failure. Horizontal scaling requires stateless application servers and distributed session handling (e.g. Redis).',
          quizOptions: [
            'Vertical scales across multiple machines; Horizontal upgrades RAM',
            'Horizontal adds more machines; Vertical upgrades hardware on existing machine',
            'Horizontal scaling is cheaper for database masters',
            'There is no difference in reliability'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'sys_3',
          categoryId: 'system_design',
          categoryName: 'System Design',
          question: 'What is Consistent Hashing and why is it essential in distributed caching?',
          answer: 'Consistent Hashing maps both servers and keys to a hash ring. When a server is added or removed, only k/N keys need remapping (where k is total keys, N is server count), preventing catastrophic cache stampedes caused by standard hash(key) % N re-hashing.',
          codeSnippet: '''// Standard Hashing: index = hash(key) % N -> When N changes, almost ALL keys invalidate!
// Consistent Hashing: Hash ring (0 to 2^32-1) + Virtual Nodes for uniform distribution.''',
          language: 'dart',
          companyTags: ['FAANG', 'FinTech'],
          difficulty: 'Hard',
          deepDiveExplanation: 'Virtual nodes (e.g., node1-A, node1-B, node1-C) map each physical machine to multiple ring positions, ensuring balanced load distribution across the cluster.',
          quizOptions: [
            'A hash function that never produces collisions',
            'A ring-based hashing technique that minimizes key remapping when nodes scale up or down',
            'A cryptographic hash for passwords',
            'A database table index strategy'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'sys_4',
          categoryId: 'system_design',
          categoryName: 'System Design',
          question: 'What are the main Caching Strategies (Cache-Aside, Write-Through, Write-Behind)?',
          answer: 'Cache-Aside: App reads from cache; on miss, reads DB and populates cache. Write-Through: App writes to cache; cache synchronously writes to DB. Write-Behind (Write-Back): App writes to cache; cache asynchronously batches writes to DB.',
          codeSnippet: '''// Cache-Aside Pattern
async function getUser(id) {
  let user = await redis.get(id);
  if (!user) {
    user = await db.queryUser(id);
    await redis.set(id, user, 'EX', 3600);
  }
  return user;
}''',
          language: 'dart',
          companyTags: ['FAANG', 'MNC', 'FinTech'],
          difficulty: 'Medium',
          deepDiveExplanation: 'Write-Behind offers highest write throughput but risks data loss if cache fails before flushing to DB. Cache-Aside is most resilient against cache node crashes.',
          quizOptions: [
            'All caching strategies write synchronously to DB first',
            'Cache-Aside lazy loads on read; Write-Through writes sync; Write-Behind writes async',
            'Caching always guarantees immediate strong consistency',
            'Write-Behind does not store data in RAM'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'sys_5',
          categoryId: 'system_design',
          categoryName: 'System Design',
          question: 'How do Message Queues (Kafka, RabbitMQ) decouple distributed systems?',
          answer: 'Message queues provide asynchronous communication, traffic spike buffering (rate leveling), and pub/sub loose coupling so producer services don\'t block waiting for consumers to process requests.',
          codeSnippet: '''// Producer pushes event and returns HTTP 202 Accepted immediately
await producer.send({ topic: 'order-created', message: orderData });
// Consumers (Billing, Shipping, Email notification) consume at their own pace.''',
          language: 'dart',
          companyTags: ['FAANG', 'FinTech', 'Startup'],
          difficulty: 'Medium',
          deepDiveExplanation: 'Kafka uses an append-only distributed commit log with partition ordering and persistent storage. RabbitMQ uses AMQP with routing exchanges and message acknowledgment queues.',
          quizOptions: [
            'They synchronize database transactions across threads',
            'They enable asynchronous processing, traffic buffering, and decoupled microservices',
            'They replace relational databases entirely',
            'They act as frontend CSS preprocessors'
          ],
          correctOptionIndex: 1,
        ),

        // ================= SQL & DATABASES =================
        Question(
          id: 'sql_1',
          categoryId: 'sql_db',
          categoryName: 'SQL & Databases',
          question: 'What are ACID properties in Relational Database Management Systems?',
          answer: 'Atomicity (all operations in transaction succeed or rollback completely), Consistency (DB transitions from one valid state to another satisfying constraints), Isolation (concurrent transactions execute independently without interference), and Durability (committed transactions persist through crashes).',
          codeSnippet: '''START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT; -- Atomicity & Durability guaranteed''',
          language: 'sql',
          companyTags: ['FAANG', 'MNC', 'FinTech'],
          difficulty: 'Medium',
          deepDiveExplanation: 'Isolation levels (Read Uncommitted, Read Committed, Repeatable Read, Serializable) trade off concurrency throughput against anomalies (Dirty Read, Non-Repeatable Read, Phantom Read).',
          quizOptions: [
            'Access, Control, Index, Data',
            'Atomicity, Consistency, Isolation, Durability',
            'Algorithm, Computation, Iteration, Division',
            'Audit, Compliance, Integrity, Deployment'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'sql_2',
          categoryId: 'sql_db',
          categoryName: 'SQL & Databases',
          question: 'Why do relational databases use B+ Trees for indexing rather than Binary Search Trees or Hash Tables?',
          answer: 'B+ Trees have high fan-out (shallow height), minimizing disk I/O seek operations. All data is stored in sorted leaf nodes linked by pointers, enabling efficient range queries (e.g. WHERE age BETWEEN 20 AND 30). Hash tables cannot do range queries.',
          codeSnippet: '''-- Index enables O(log_B N) search AND fast range scan on leaf pointers:
CREATE INDEX idx_users_created_at ON users(created_at);
SELECT * FROM users WHERE created_at >= '2026-01-01';''',
          language: 'sql',
          companyTags: ['FAANG', 'FinTech'],
          difficulty: 'Hard',
          deepDiveExplanation: 'A B+ tree node fits on a disk block/page (typically 4KB-16KB). With a fan-out of 100+, a 3-level B+ tree can index millions of rows with at most 3-4 disk block reads.',
          quizOptions: [
            'Hash tables are slower than BSTs for exact match',
            'B+ Trees have high fan-out (low disk I/O) and linked leaf nodes for efficient range queries',
            'B+ Trees require zero memory',
            'Relational DBs only use AVL trees'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'sql_3',
          categoryId: 'sql_db',
          categoryName: 'SQL & Databases',
          question: 'What is the difference between Clustered and Non-Clustered Indexes?',
          answer: 'A Clustered Index dictates the physical on-disk sorting order of table rows (only 1 per table, typically the Primary Key). A Non-Clustered Index is a separate structure containing index keys and pointers back to the physical rows.',
          codeSnippet: '''-- Clustered: Physical data rows are stored in the leaf nodes of this index
ALTER TABLE users ADD CONSTRAINT pk_users PRIMARY KEY (id);

-- Non-Clustered: Index leaf points to Primary Key value (in InnoDB)
CREATE INDEX idx_user_email ON users(email);''',
          language: 'sql',
          companyTags: ['FAANG', 'MNC', 'FinTech'],
          difficulty: 'Medium',
          deepDiveExplanation: 'In MySQL InnoDB, secondary non-clustered indexes point to the clustered index primary key. A query with non-indexed fields triggers a "bookmark lookup" to the clustered index unless a covering index is used.',
          quizOptions: [
            'Tables can have unlimited clustered indexes',
            'Clustered index defines physical data order (max 1); Non-clustered points to rows (multiple allowed)',
            'Non-clustered indexes are stored inside the original table rows',
            'There is no performance difference'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'sql_4',
          categoryId: 'sql_db',
          categoryName: 'SQL & Databases',
          question: 'What are SQL Window Functions and how do they differ from GROUP BY?',
          answer: 'Window functions perform calculations across a set of table rows related to the current row without collapsing rows into a single summary output, unlike GROUP BY.',
          codeSnippet: '''-- Rank employees within each department without collapsing rows
SELECT 
  id, name, department, salary,
  DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_salary_rank
FROM employees;''',
          language: 'sql',
          companyTags: ['FAANG', 'FinTech'],
          difficulty: 'Medium',
          deepDiveExplanation: 'Window functions (ROW_NUMBER, RANK, DENSE_RANK, LEAD, LAG) execute after WHERE and HAVING clauses during query evaluation.',
          quizOptions: [
            'Window functions collapse all rows into a single row like SUM()',
            'Window functions compute aggregates over a partition while preserving individual rows',
            'Window functions only work in SQLite',
            'Window functions execute before the WHERE filter'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'sql_5',
          categoryId: 'sql_db',
          categoryName: 'SQL & Databases',
          question: 'What is Database Sharding vs Read Replication?',
          answer: 'Read replication copies data from a master to replica nodes to scale read queries. Sharding partitions data horizontally across multiple database nodes based on a shard key to scale both write and storage capacity.',
          codeSnippet: '''// Sharding by User ID hash:
// Node 1: User IDs hash % 3 == 0
// Node 2: User IDs hash % 3 == 1
// Node 3: User IDs hash % 3 == 2''',
          language: 'dart',
          companyTags: ['FAANG', 'FinTech', 'Startup'],
          difficulty: 'Hard',
          deepDiveExplanation: 'Sharding introduces complexity with cross-shard joins, distributed transactions (Two-Phase Commit), and rebalancing when shards become unevenly loaded (hotspots).',
          quizOptions: [
            'Replication scales writes; Sharding scales reads only',
            'Replication clones DB for read scaling; Sharding partitions data horizontally for write/storage scaling',
            'Sharding is only used in single-threaded systems',
            'They are identical database configurations'
          ],
          correctOptionIndex: 1,
        ),

        // ================= JAVA & OOP =================
        Question(
          id: 'java_1',
          categoryId: 'java_oop',
          categoryName: 'Java & OOP',
          question: 'Explain the four core principles of Object-Oriented Programming (OOP).',
          answer: 'Encapsulation (bundling data and methods while hiding internal state via access modifiers), Abstraction (exposing simple interfaces while hiding implementation complexity), Inheritance (hierarchical code reuse and taxonomy), and Polymorphism (ability of an object to take on many forms via overloading and overriding).',
          codeSnippet: '''// Polymorphism via Interface Abstraction
public interface PaymentGateway {
    boolean process(double amount);
}
public class RazorpayGateway implements PaymentGateway {
    @Override
    public boolean process(double amount) { return true; }
}''',
          language: 'java',
          companyTags: ['MNC', 'FinTech'],
          difficulty: 'Easy',
          deepDiveExplanation: 'Prefer composition over inheritance to avoid fragile base class problems and tight coupling in enterprise software architecture.',
          quizOptions: [
            'Aggregation, Compilation, Linking, Loading',
            'Encapsulation, Abstraction, Inheritance, Polymorphism',
            'Pointers, References, Garbage Collection, Heap',
            'Threads, Sockets, Processes, Files'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'java_2',
          categoryId: 'java_oop',
          categoryName: 'Java & OOP',
          question: 'What is the difference between String, StringBuilder, and StringBuffer in Java?',
          answer: 'String is immutable (modifications create new objects in String Constant Pool). StringBuilder is mutable and not thread-safe (fastest for single-threaded string concatenation). StringBuffer is mutable and thread-safe (synchronized methods).',
          codeSnippet: '''// Fast, mutable single-threaded string building:
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    sb.append(i).append(",");
}
String result = sb.toString();''',
          language: 'java',
          companyTags: ['FAANG', 'MNC', 'FinTech'],
          difficulty: 'Easy',
          deepDiveExplanation: 'Because String is immutable, repeated concatenation in a loop (str += "a") generates O(n^2) garbage objects in memory. Always use StringBuilder inside loops.',
          quizOptions: [
            'String is mutable; StringBuilder is immutable',
            'String is immutable; StringBuilder is mutable/non-synchronized; StringBuffer is mutable/synchronized',
            'StringBuffer is faster than StringBuilder',
            'All three share identical memory implementations'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'java_3',
          categoryId: 'java_oop',
          categoryName: 'Java & OOP',
          question: 'How does Java Garbage Collection work (Heap Memory Generations)?',
          answer: 'Java Heap is divided into Young Generation (Eden space and two Survivor spaces S0, S1) and Old Generation (Tenured). New objects are allocated in Eden. Minor GC cleans Young Gen and promotes long-lived objects to Tenured. Major/Full GC cleans Old Gen.',
          codeSnippet: '''// JVM GC Tuning flags:
// -Xms4g (Initial Heap) -Xmx8g (Max Heap) -XX:+UseG1GC''',
          language: 'java',
          companyTags: ['FAANG', 'MNC', 'FinTech'],
          difficulty: 'Hard',
          deepDiveExplanation: 'The Weak Generational Hypothesis states most objects die young. Generational collectors (G1, ZGC, Shenandoah) exploit this to collect short-lived objects with sub-millisecond pause times.',
          quizOptions: [
            'Java requires manual delete statements like C++',
            'Young Gen (Eden/Survivor) for new objects; Tenured Old Gen for long-lived objects',
            'GC executes only when the OS runs out of RAM',
            'Heap is divided into Code, Stack, and Registers only'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'java_4',
          categoryId: 'java_oop',
          categoryName: 'Java & OOP',
          question: 'What is the contract between equals() and hashCode() in Java?',
          answer: 'If two objects are equal according to equals(), they MUST have the same hashCode(). If two objects have the same hashCode(), they are NOT necessarily equal (hash collision). Violating this contract breaks HashMaps and HashSets.',
          codeSnippet: '''@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof User user)) return false;
    return id == user.id && Objects.equals(name, user.name);
}

@Override
public int hashCode() {
    return Objects.hash(id, name);
}''',
          language: 'java',
          companyTags: ['FAANG', 'MNC', 'FinTech'],
          difficulty: 'Medium',
          deepDiveExplanation: 'When inserting into a HashMap, the key\'s hashCode() determines the bucket index. If two equal keys return different hash codes, they land in different buckets, making the object unretrievable.',
          quizOptions: [
            'hashCode() must return distinct values for equal objects',
            'Equal objects MUST produce identical hash codes; equal hash codes may collide',
            'Overriding equals() automatically implements hashCode()',
            'There is no requirement between the two methods'
          ],
          correctOptionIndex: 1,
        ),
        Question(
          id: 'java_5',
          categoryId: 'java_oop',
          categoryName: 'Java & OOP',
          question: 'What is the difference between Comparable and Comparator in Java?',
          answer: 'Comparable defines the natural sorting order for a class by implementing compareTo(T o) on the class itself. Comparator defines external custom sorting logic by implementing compare(T o1, T o2) in a separate class or lambda.',
          codeSnippet: '''// Custom sort by salary descending using Comparator lambda
List<Employee> list = getEmployees();
list.sort(Comparator.comparingDouble(Employee::getSalary).reversed());''',
          language: 'java',
          companyTags: ['MNC', 'FinTech'],
          difficulty: 'Easy',
          deepDiveExplanation: 'Classes like String and Integer implement Comparable<T>. Comparator allows multiple sorting strategies (by name, by date, by price) without modifying the original domain entity.',
          quizOptions: [
            'Comparable is external; Comparator is natural internal order',
            'Comparable implements compareTo() internally; Comparator implements compare() externally',
            'Comparable is only for primitive types',
            'Both must be implemented simultaneously'
          ],
          correctOptionIndex: 1,
        ),
      ];
}
