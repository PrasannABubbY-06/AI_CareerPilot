import '/screens/ai_modules/skill_analyzer/models/question_model.dart';

final Map<String, List<QuestionModel>> skillQuestions = {

  // ===================== FLUTTER =====================
  "flutter": [
    QuestionModel(
      question: "What is the main programming language used in Flutter?",
      options: ["Java", "Kotlin", "Dart", "Swift"],
      correctIndex: 2,
      level: "beginner",
    ),
    QuestionModel(
      question: "What is the core concept used to build UI in Flutter?",
      options: ["XML", "Widgets", "Layouts", "Fragments"],
      correctIndex: 1,
      level: "beginner",
    ),
    QuestionModel(
      question: "What is the purpose of Hot Reload in Flutter?",
      options: ["App build", "Fast UI updates", "Debug only", "Testing"],
      correctIndex: 1,
      level: "beginner",
    ),
    QuestionModel(
      question: "What is the entry point of a Flutter application?",
      options: ["start()", "main()", "run()", "init()"],
      correctIndex: 1,
      level: "beginner",
    ),

    QuestionModel(
      question: "When should you use a StatefulWidget?",
      options: ["Static UI", "Dynamic UI", "Only UI", "No logic"],
      correctIndex: 1,
      level: "intermediate",
    ),
    QuestionModel(
      question: "What is the purpose of setState()?",
      options: ["Build widget", "Update UI", "Store data", "Navigation"],
      correctIndex: 1,
      level: "intermediate",
    ),
    QuestionModel(
      question: "Which is used for navigation in Flutter?",
      options: ["Intent", "Navigator", "Router", "Activity"],
      correctIndex: 1,
      level: "intermediate",
    ),
    QuestionModel(
      question: "Why is MediaQuery used in Flutter?",
      options: ["API calls", "Device size", "Storage", "Theme"],
      correctIndex: 1,
      level: "intermediate",
    ),

    QuestionModel(
      question: "Which is the best state management approach in Flutter?",
      options: ["setState", "Provider", "Bloc", "All"],
      correctIndex: 3,
      level: "advanced",
    ),
    QuestionModel(
      question: "Why are Isolates used in Flutter?",
      options: ["UI", "Parallel tasks", "Navigation", "Animation"],
      correctIndex: 1,
      level: "advanced",
    ),
    QuestionModel(
      question: "What is the role of BuildContext?",
      options: ["Widget tree", "API", "Storage", "Thread"],
      correctIndex: 0,
      level: "advanced",
    ),
    QuestionModel(
      question: "How can you improve performance in Flutter?",
      options: ["Rebuild all", "Use const", "More widgets", "Avoid keys"],
      correctIndex: 1,
      level: "advanced",
    ),
  ],

  // ===================== PYTHON =====================
  "python": [
    QuestionModel(
      question: "Is Python an interpreted language?",
      options: ["Yes", "No", "Sometimes", "Compiled"],
      correctIndex: 0,
      level: "beginner",
    ),
    QuestionModel(
      question: "Do we need to declare variable types in Python?",
      options: ["Yes", "No", "Sometimes", "Only int"],
      correctIndex: 1,
      level: "beginner",
    ),
    QuestionModel(
      question: "What is the file extension of Python files?",
      options: [".java", ".py", ".js", ".cpp"],
      correctIndex: 1,
      level: "beginner",
    ),
    QuestionModel(
      question: "What is the purpose of the print() function?",
      options: ["Input", "Output", "Loop", "Condition"],
      correctIndex: 1,
      level: "beginner",
    ),

    QuestionModel(
      question: "What is the difference between List and Tuple?",
      options: ["Mutable vs Immutable", "Same", "Speed", "Syntax"],
      correctIndex: 0,
      level: "intermediate",
    ),
    QuestionModel(
      question: "What does a dictionary store in Python?",
      options: ["Index", "Key-Value", "Only keys", "Only values"],
      correctIndex: 1,
      level: "intermediate",
    ),
    QuestionModel(
      question: "Which keyword is used for exception handling?",
      options: ["try-except", "catch", "error", "handle"],
      correctIndex: 0,
      level: "intermediate",
    ),
    QuestionModel(
      question: "Which keyword is used to define a function in Python?",
      options: ["function", "def", "fun", "method"],
      correctIndex: 1,
      level: "intermediate",
    ),

    QuestionModel(
      question: "How does Python manage memory?",
      options: ["Manual", "Garbage Collection", "Static", "None"],
      correctIndex: 1,
      level: "advanced",
    ),
    QuestionModel(
      question: "What is a lambda function?",
      options: ["Anonymous", "Recursive", "Named", "Async"],
      correctIndex: 0,
      level: "advanced",
    ),
    QuestionModel(
      question: "What is the purpose of __init__()?",
      options: ["Destructor", "Constructor", "Method", "Variable"],
      correctIndex: 1,
      level: "advanced",
    ),
    QuestionModel(
      question: "Why are virtual environments used?",
      options: ["Isolation", "Speed", "UI", "Testing"],
      correctIndex: 0,
      level: "advanced",
    ),
  ],

  // ===================== JAVA =====================
  "java": [
    QuestionModel(
      question: "Is Java platform independent?",
      options: ["Yes", "No", "Sometimes", "Only Linux"],
      correctIndex: 0,
      level: "beginner",
    ),
    QuestionModel(
      question: "What is the entry point method of a Java program?",
      options: ["start()", "run()", "main()", "init()"],
      correctIndex: 2,
      level: "beginner",
    ),
    QuestionModel(
      question: "What is the full form of JVM?",
      options: [
        "Java Virtual Machine",
        "Java Variable Model",
        "Just VM",
        "None"
      ],
      correctIndex: 0,
      level: "beginner",
    ),
    QuestionModel(
      question: "Is Java a strongly typed language?",
      options: ["Yes", "No", "Dynamic", "Optional"],
      correctIndex: 0,
      level: "beginner",
    ),

    QuestionModel(
      question: "What are the pillars of Object-Oriented Programming?",
      options: [
        "Encapsulation",
        "Inheritance",
        "Polymorphism",
        "All"
      ],
      correctIndex: 3,
      level: "intermediate",
    ),
    QuestionModel(
      question: "Why are interfaces used in Java?",
      options: [
        "Multiple inheritance",
        "Object creation",
        "Memory",
        "Thread"
      ],
      correctIndex: 0,
      level: "intermediate",
    ),
    QuestionModel(
      question: "Which is the superclass of all exceptions?",
      options: ["Throwable", "Error", "Exception", "Object"],
      correctIndex: 0,
      level: "intermediate",
    ),
    QuestionModel(
      question: "What is the purpose of the final keyword?",
      options: ["Changeable", "Constant", "Optional", "Static"],
      correctIndex: 1,
      level: "intermediate",
    ),

    QuestionModel(
      question: "What does JDK contain?",
      options: ["JVM only", "JRE only", "JRE + tools", "Compiler only"],
      correctIndex: 2,
      level: "advanced",
    ),
    QuestionModel(
      question: "How is garbage collection handled in Java?",
      options: ["Manual", "Automatic", "Optional", "None"],
      correctIndex: 1,
      level: "advanced",
    ),
    QuestionModel(
      question: "How can multithreading be achieved in Java?",
      options: ["Runnable", "Thread", "Both", "None"],
      correctIndex: 2,
      level: "advanced",
    ),
    QuestionModel(
      question: "Which memory areas are used in Java?",
      options: ["Heap", "Stack", "Method Area", "All"],
      correctIndex: 3,
      level: "advanced",
    ),
  ],

  // ===================== SQL =====================
  "sql": [
    QuestionModel(
      question: "What is the full form of SQL?",
      options: [
        "Structured Query Language",
        "Simple Query Language",
        "Sequential Query",
        "None"
      ],
      correctIndex: 0,
      level: "beginner",
    ),
    QuestionModel(
      question: "What is the purpose of the SELECT keyword?",
      options: ["Insert", "Update", "Fetch", "Delete"],
      correctIndex: 2,
      level: "beginner",
    ),
    QuestionModel(
      question: "Which command is used to create a table?",
      options: ["CREATE", "INSERT", "ALTER", "UPDATE"],
      correctIndex: 0,
      level: "beginner",
    ),
    QuestionModel(
      question: "What is the main property of a primary key?",
      options: ["Duplicate", "Unique", "Null", "Optional"],
      correctIndex: 1,
      level: "beginner",
    ),

    QuestionModel(
      question: "What is the purpose of the WHERE clause?",
      options: ["Sort", "Filter", "Group", "Join"],
      correctIndex: 1,
      level: "intermediate",
    ),
    QuestionModel(
      question: "Why are JOINs used in SQL?",
      options: [
        "Combine tables",
        "Delete data",
        "Insert",
        "Filter"
      ],
      correctIndex: 0,
      level: "intermediate",
    ),
    QuestionModel(
      question: "GROUP BY is commonly used with which functions?",
      options: ["SUM", "AVG", "COUNT", "All"],
      correctIndex: 3,
      level: "intermediate",
    ),
    QuestionModel(
      question: "What does an index improve?",
      options: [
        "Storage",
        "Performance",
        "Security",
        "Design"
      ],
      correctIndex: 1,
      level: "intermediate",
    ),

    QuestionModel(
      question: "What is the main goal of normalization?",
      options: [
        "Reduce redundancy",
        "Increase size",
        "Speed",
        "Security"
      ],
      correctIndex: 0,
      level: "advanced",
    ),
    QuestionModel(
      question: "What does ACID ensure in databases?",
      options: [
        "Transaction safety",
        "Speed",
        "UI",
        "Memory"
      ],
      correctIndex: 0,
      level: "advanced",
    ),
    QuestionModel(
      question: "What is a stored procedure?",
      options: [
        "Reusable SQL",
        "Index",
        "Table",
        "View"
      ],
      correctIndex: 0,
      level: "advanced",
    ),
    QuestionModel(
      question: "When does a deadlock occur?",
      options: [
        "Circular wait",
        "Single query",
        "Index",
        "Insert"
      ],
      correctIndex: 0,
      level: "advanced",
    ),
  ],

  // ===================== DSA =====================
  "dsa": [
    QuestionModel(
      question: "What does DSA stand for?",
      options: [
        "Data Structures & Algorithms",
        "Data System",
        "Design Algo",
        "None"
      ],
      correctIndex: 0,
      level: "beginner",
    ),
    QuestionModel(
      question: "How does an array store data?",
      options: [
        "Sequential",
        "Random",
        "Tree",
        "Graph"
      ],
      correctIndex: 0,
      level: "beginner",
    ),
    QuestionModel(
      question: "Which principle does a stack follow?",
      options: ["FIFO", "LIFO", "Random", "None"],
      correctIndex: 1,
      level: "beginner",
    ),
    QuestionModel(
      question: "Which principle does a queue follow?",
      options: ["LIFO", "FIFO", "Random", "None"],
      correctIndex: 1,
      level: "beginner",
    ),

    QuestionModel(
      question: "What is the time complexity of binary search?",
      options: ["O(n)", "O(log n)", "O(n²)", "O(1)"],
      correctIndex: 1,
      level: "intermediate",
    ),
    QuestionModel(
      question: "What is the main advantage of a linked list?",
      options: [
        "Dynamic size",
        "Fast access",
        "Low memory",
        "None"
      ],
      correctIndex: 0,
      level: "intermediate",
    ),
    QuestionModel(
      question: "What property does the root of a tree have?",
      options: ["Parent", "Child", "No parent", "Two parents"],
      correctIndex: 2,
      level: "intermediate",
    ),
    QuestionModel(
      question: "Graphs are composed of?",
      options: ["Nodes & edges", "Arrays", "Stacks", "Queues"],
      correctIndex: 0,
      level: "intermediate",
    ),

    QuestionModel(
      question: "What is the average time complexity of Quick Sort?",
      options: ["O(n²)", "O(n log n)", "O(n)", "O(1)"],
      correctIndex: 1,
      level: "advanced",
    ),
    QuestionModel(
      question: "Which data structure is used in a priority queue?",
      options: ["Heap", "Stack", "Array", "Graph"],
      correctIndex: 0,
      level: "advanced",
    ),
    QuestionModel(
      question: "Depth First Search (DFS) primarily uses?",
      options: ["Stack", "Queue", "Array", "Tree"],
      correctIndex: 0,
      level: "advanced",
    ),
    QuestionModel(
      question: "Dynamic programming is used to solve?",
      options: [
        "Overlapping subproblems",
        "Simple loops",
        "UI",
        "Storage"
      ],
      correctIndex: 0,
      level: "advanced",
    ),
  ],
};
