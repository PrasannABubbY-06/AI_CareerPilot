import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SkillCacheManager {
  // Memory Cache
  static final Map<String, String> _memoryCache = {};

  // Pre-populated skills Knowledge Base with direct, verified resource links
  static final Map<String, String> _prepopulatedRoadmaps = {
    "flutter": """
### 🗺️ Flutter Roadmap:
- **Step 1**: Master Dart programming basics (variables, control flow, functions, OOP).
- **Step 2**: Understand Widget trees, layouts, Stateless vs. Stateful Widgets, and basic routing.
- **Step 3**: Master State Management (Provider, Riverpod, or Bloc).
- **Step 4**: Practice calling REST APIs, asynchronous programming (Futures, Streams), and local database storage.
- **Step 5**: Deploy apps to Android Google Play Store and iOS App Store.
### 📚 Recommended Resources:
- 📺 [Watch Complete Flutter Course on YouTube](https://www.youtube.com/watch?v=VPvVD8t02U8)
- 📝 [Official Flutter Documentation](https://docs.flutter.dev)
- 📖 [GeeksforGeeks Flutter Notes](https://www.geeksforgeeks.org/flutter-tutorial/)
- 💻 [Flutter Practice Projects](https://github.com/flutter/samples)
""",
    "dart": """
### 🗺️ Dart Roadmap:
- **Step 1**: Understand basic syntax, data types, variables, and operators.
- **Step 2**: Learn control flow statement, lists, maps, and loops.
- **Step 3**: Master Object-Oriented Programming (Classes, inheritance, mixins).
- **Step 4**: Understand asynchronous programming (async, await, Future, Streams).
- **Step 5**: Learn Dart collection methods and type system.
### 📚 Recommended Resources:
- 📺 [Watch Complete Dart Course on YouTube](https://www.youtube.com/watch?v=JZukfxvc7Mc)
- 📝 [Official Dart Documentation](https://dart.dev/guides)
- 📖 [GeeksforGeeks Dart Notes](https://www.geeksforgeeks.org/dart-tutorial/)
- 💻 [DartPad Practice](https://dartpad.dev/)
""",
    "firebase": """
### 🗺️ Firebase Roadmap:
- **Step 1**: Set up a Firebase project and connect it to your application.
- **Step 2**: Learn Authentication (Email/Password, Google Sign-in).
- **Step 3**: Master Cloud Firestore for real-time CRUD operations and querying.
- **Step 4**: Implement Firebase Storage for uploading and downloading files.
- **Step 5**: Use Firebase Cloud Functions for backend logic and notifications.
### 📚 Recommended Resources:
- 📺 [Watch Complete Firebase Course on YouTube](https://www.youtube.com/watch?v=_L8j-ZC83y4)
- 📝 [Official Firebase Documentation](https://firebase.google.com/docs)
- 📖 [FreeCodeCamp Firebase Notes](https://www.freecodecamp.org/news/tag/firebase/)
- 💻 [Firebase Codelabs](https://firebase.google.com/codelabs)
""",
    "react": """
### 🗺️ React Roadmap:
- **Step 1**: Master modern JavaScript (ES6+, Arrow Functions, Destructuring).
- **Step 2**: Understand JSX, Components, Props, and State.
- **Step 3**: Learn hooks: useState, useEffect, useContext, and custom hooks.
- **Step 4**: Master client-side routing with React Router.
- **Step 5**: Learn State Management tools like Redux Toolkit or Zustand.
### 📚 Recommended Resources:
- 📺 [Watch Complete React Course on YouTube](https://www.youtube.com/watch?v=Ke90Tje7VS0)
- 📝 [Official React Documentation](https://react.dev)
- 📖 [GeeksforGeeks React Notes](https://www.geeksforgeeks.org/reactjs-tutorial/)
- 💻 [React Practice Challenges](https://github.com/sudheerj/reactjs-interview-questions)
""",
    "javascript": """
### 🗺️ JavaScript Roadmap:
- **Step 1**: Learn variables, primitives, operators, and basic logic.
- **Step 2**: Understand arrays, objects, functions, and scoping rules.
- **Step 3**: Master DOM manipulation and Event listeners.
- **Step 4**: Master Asynchronous JS (Promises, async/await, Fetch API).
- **Step 5**: Learn ES6+ features, closures, prototype system, and modules.
### 📚 Recommended Resources:
- 📺 [Watch Complete JavaScript Course on YouTube](https://www.youtube.com/watch?v=W6NZfCO5SIk)
- 📝 [MDN Web Docs for JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- 📖 [W3Schools JavaScript Notes](https://www.w3schools.com/js/)
- 💻 [JavaScript30 Practice Projects](https://javascript30.com/)
""",
    "typescript": """
### 🗺️ TypeScript Roadmap:
- **Step 1**: Learn how to install and compile TypeScript files.
- **Step 2**: Understand basic types (string, number, boolean) and type annotations.
- **Step 3**: Learn Interfaces, Type Aliases, and Union/Intersection types.
- **Step 4**: Master Generics, Utility Types, and Decorators.
- **Step 5**: Configure tsconfig.json for strict type safety.
### 📚 Recommended Resources:
- 📺 [Watch Complete TypeScript Course on YouTube](https://www.youtube.com/watch?v=d56mG7DezGs)
- 📝 [Official TypeScript Documentation](https://www.typescriptlang.org/docs/)
- 📖 [FreeCodeCamp TypeScript Notes](https://www.freecodecamp.org/news/learn-typescript-beginners-guide/)
- 💻 [TypeScript Exercises](https://typescript-exercises.github.io/)
""",
    "python": """
### 🗺️ Python Roadmap:
- **Step 1**: Learn basic syntax, variables, lists, dicts, and operators.
- **Step 2**: Understand conditional blocks, loops, functions, and arguments.
- **Step 3**: Master Object-Oriented Python (Classes, inheritance, properties).
- **Step 4**: Learn File handling, Exception handling, and Module imports.
- **Step 5**: Learn common libraries like NumPy, Pandas, or requests.
### 📚 Recommended Resources:
- 📺 [Watch Complete Python Course on YouTube](https://www.youtube.com/watch?v=_uQrJ0TkZlc)
- 📝 [Official Python Documentation](https://docs.python.org/3/)
- 📖 [GeeksforGeeks Python Notes](https://www.geeksforgeeks.org/python-programming-language/)
- 💻 [HackerRank Python Practice](https://www.hackerrank.com/domains/python)
""",
    "java": """
### 🗺️ Java Roadmap:
- **Step 1**: Learn syntax, primitive data types, variables, and loops.
- **Step 2**: Master OOP (Inheritance, Polymorphism, Abstraction, Encapsulation).
- **Step 3**: Learn Java Collections Framework (ArrayList, HashMap, HashSet).
- **Step 4**: Master Exception Handling and Multithreading.
- **Step 5**: Learn Build tools (Maven/Gradle) and basic database connectivity.
### 📚 Recommended Resources:
- 📺 [Watch Complete Java Course on YouTube](https://www.youtube.com/watch?v=A74TOX803D0)
- 📝 [Official Oracle Java Documentation](https://docs.oracle.com/en/java/)
- 📖 [GeeksforGeeks Java Notes](https://www.geeksforgeeks.org/java/)
- 💻 [LeetCode Java Practice](https://leetcode.com/)
""",
    "c": """
### 🗺️ C Roadmap:
- **Step 1**: Learn syntax, control flow statements, and operators.
- **Step 2**: Master functions, local/global scope, and structures.
- **Step 3**: Master Pointers, memory addresses, and pointer arithmetic.
- **Step 4**: Understand dynamic memory allocation (malloc, calloc, free).
- **Step 5**: Learn file handling operations in C.
### 📚 Recommended Resources:
- 📺 [Watch Complete C Programming Course on YouTube](https://www.youtube.com/watch?v=KJgsSFOSQv0)
- 📝 [C Reference Documentation](https://en.cppreference.com/w/c)
- 📖 [GeeksforGeeks C Notes](https://www.geeksforgeeks.org/c-programming-language/)
- 💻 [HackerRank C Practice](https://www.hackerrank.com/domains/c)
""",
    "c++": """
### 🗺️ C++ Roadmap:
- **Step 1**: Learn variables, loops, conditionals, and standard syntax.
- **Step 2**: Understand functions, pointers, references, and structures.
- **Step 3**: Master OOP, Constructor/Destructor, and operator overloading.
- **Step 4**: Master Standard Template Library (STL) - vectors, maps, stacks, queues.
- **Step 5**: Learn dynamic memory management and Smart Pointers.
### 📚 Recommended Resources:
- 📺 [Watch Complete C++ Course on YouTube](https://www.youtube.com/watch?v=vLnPwxZdW4Y)
- 📝 [C++ Standard Reference Docs](https://en.cppreference.com/w/cpp)
- 📖 [GeeksforGeeks C++ Notes](https://www.geeksforgeeks.org/cpp-tutorial/)
- 💻 [HackerRank C++ Practice](https://www.hackerrank.com/domains/cpp)
""",
    "sql": """
### 🗺️ SQL Roadmap:
- **Step 1**: Learn relational database concepts and CRUD basics.
- **Step 2**: Understand SELECT queries, WHERE clauses, sorting, and pagination.
- **Step 3**: Master JOINS (Inner, Left, Right, Full Outer Joins).
- **Step 4**: Understand aggregation (GROUP BY, HAVING) and Subqueries.
- **Step 5**: Learn indexes, database views, and transaction controls.
### 📚 Recommended Resources:
- 📺 [Watch Complete SQL Course on YouTube](https://www.youtube.com/watch?v=HXV3zeQKqGY)
- 📝 [W3Schools SQL Reference](https://www.w3schools.com/sql/)
- 📖 [GeeksforGeeks SQL Notes](https://www.geeksforgeeks.org/sql-tutorial/)
- 💻 [SQLBolt Practice](https://sqlbolt.com/)
""",
    "mysql": """
### 🗺️ MySQL Roadmap:
- **Step 1**: Install MySQL Workbench and set up a local database connection.
- **Step 2**: Learn DDL commands (CREATE, ALTER, DROP tables).
- **Step 3**: Master indexes, primary keys, and foreign keys database constraints.
- **Step 4**: Understand stored procedures, functions, and database triggers.
- **Step 5**: Practice database optimization and explain plan utility.
### 📚 Recommended Resources:
- 📺 [Watch Complete MySQL Course on YouTube](https://www.youtube.com/watch?v=7S_tz1z_5bA)
- 📝 [Official MySQL Documentation Reference](https://dev.mysql.com/doc/)
- 📖 [GeeksforGeeks MySQL Notes](https://www.geeksforgeeks.org/mysql-tutorial/)
- 💻 [HackerRank SQL Practice](https://www.hackerrank.com/domains/sql)
""",
    "mongodb": """
### 🗺️ MongoDB Roadmap:
- **Step 1**: Understand NoSQL database concepts and document modeling.
- **Step 2**: Learn CRUD operations and shell queries.
- **Step 3**: Master MongoDB aggregation pipelines and operators.
- **Step 4**: Implement indexes for query performance optimization.
- **Step 5**: Understand MongoDB schemas design validation and replica sets.
### 📚 Recommended Resources:
- 📺 [Watch Complete MongoDB Course on YouTube](https://www.youtube.com/watch?v=c2M-rlkkT5o)
- 📝 [Official MongoDB Documentation](https://www.mongodb.com/docs/)
- 📖 [GeeksforGeeks MongoDB Notes](https://www.geeksforgeeks.org/mongodb/)
- 💻 [MongoDB University](https://learn.mongodb.com/)
""",
    "node.js": """
### 🗺️ Node.js Roadmap:
- **Step 1**: Understand Event Loop, Single-Threaded Architecture, and V8 engine.
- **Step 2**: Learn Node core modules (fs, path, http, events).
- **Step 3**: Master npm, package.json management, and ES Modules.
- **Step 4**: Understand asynchronous flow (callbacks, Promises, async/await).
- **Step 5**: Learn file streams, buffers, and basic HTTP server setup.
### 📚 Recommended Resources:
- 📺 [Watch Node.js Full Course on YouTube](https://www.youtube.com/watch?v=Oe421EPjeBE)
- 📝 [Official Node.js Docs Guide](https://nodejs.org/en/docs/)
- 📖 [GeeksforGeeks Node.js Notes](https://www.geeksforgeeks.org/nodejs/)
- 💻 [Node.js Best Practices Repository GitHub](https://github.com/goldbergyoni/nodebestpractices)
""",
    "express.js": """
### 🗺️ Express.js Roadmap:
- **Step 1**: Understand middleware architecture and HTTP methods.
- **Step 2**: Set up application routes, routers, and dynamic routing.
- **Step 3**: Master request parsing, headers, query parameters, and body parser.
- **Step 4**: Implement error handling middleware and validation filters.
- **Step 5**: Connect Express apps to databases (MongoDB via Mongoose, SQL via Sequelize).
### 📚 Recommended Resources:
- 📺 [Watch Complete Express.js Course on YouTube](https://www.youtube.com/watch?v=SccSCuHhOw0)
- 📝 [Official Express.js Guide Documentation](https://expressjs.com)
- 📖 [MDN Express.js Notes](https://developer.mozilla.org/en-US/docs/Learn/Server-side/Express_Nodejs)
- 💻 [Express API Boilerplate GitHub](https://github.com/hagopj13/node-express-boilerplate)
""",
    "git": """
### 🗺️ Git Roadmap:
- **Step 1**: Understand version control systems and repository initialization.
- **Step 2**: Learn staging, committing changes, and viewing repository history.
- **Step 3**: Master Git branching, merging, checkout, and restoring files.
- **Step 4**: Resolve merge conflicts and use git diff.
- **Step 5**: Learn git remote commands (clone, fetch, pull, push).
### 📚 Recommended Resources:
- 📺 [Watch Complete Git Course on YouTube](https://www.youtube.com/watch?v=RGOj5yH7evk)
- 📝 [Official Git Book Reference Docs](https://git-scm.com/doc)
- 📖 [Atlassian Git Tutorial Notes](https://www.atlassian.com/git/tutorials)
- 💻 [Git Branching Practice](https://learngitbranching.js.org/)
""",
    "github": """
### 🗺️ GitHub Roadmap:
- **Step 1**: Set up a profile, generate SSH keys, and configure Git.
- **Step 2**: Learn how to create pull requests, review changes, and merge code.
- **Step 3**: Understand GitHub issues, markdown syntax, and project boards.
- **Step 4**: Understand GitHub Pages hosting and release tags.
- **Step 5**: Learn basic GitHub Actions workflows for CI/CD automation.
### 📚 Recommended Resources:
- 📺 [Watch GitHub Guide Course on YouTube](https://www.youtube.com/watch?v=Ez8F0nW6S-w)
- 📝 [Official GitHub Documentation Help](https://docs.github.com)
- 📖 [GitHub Skills Tutorial](https://skills.github.com/)
- 💻 [Interactive Git & GitHub Exercises GitHub](https://github.com/jlord/git-it-electron)
""",
    "data structures": """
### 🗺️ Data Structures Roadmap:
- **Step 1**: Master arrays, list implementations, and multidimensional structures.
- **Step 2**: Understand Linked Lists (Singly, Doubly, and Circular).
- **Step 3**: Master Stack and Queue data structures and applications.
- **Step 4**: Learn Trees (Binary Search Tree, AVL, Tries, Heaps).
- **Step 5**: Understand Hash Tables, hash functions, and collision resolution techniques.
### 📚 Recommended Resources:
- 📺 [Watch Complete Data Structures Course on YouTube](https://www.youtube.com/watch?v=8hly31xKli0)
- 📝 [GeeksforGeeks Data Structures Guide](https://www.geeksforgeeks.org/data-structures/)
- 📖 [FreeCodeCamp DSA Notes](https://www.freecodecamp.org/news/data-structures-and-algorithms-guide/)
- 💻 [LeetCode Practice](https://leetcode.com/)
""",
    "dsa": """
### 🗺️ DSA Roadmap:
- **Step 1**: Master arrays, string manipulation, and list implementations.
- **Step 2**: Learn fundamental algorithms (Sorting, Searching, Recursion).
- **Step 3**: Understand Linked Lists, Stacks, and Queues.
- **Step 4**: Learn Trees, Graphs, and Hash Tables.
- **Step 5**: Master advanced techniques (Dynamic Programming, Greedy Algorithms).
### 📚 Recommended Resources:
- 📺 [Watch Complete DSA Course on YouTube](https://www.youtube.com/watch?v=8hly31xKli0)
- 📝 [GeeksforGeeks DSA Guide](https://www.geeksforgeeks.org/data-structures/)
- 📖 [W3Schools DSA Notes](https://www.w3schools.com/dsa/)
- 💻 [LeetCode Practice](https://leetcode.com/)
""",
    "algorithms": """
### 🗺️ Algorithms Roadmap:
- **Step 1**: Understand Big-O notation, Time complexity, and Space complexity.
- **Step 2**: Learn Searching algorithms (Linear, Binary Search).
- **Step 3**: Learn Sorting algorithms (Bubble, Insertion, Quick, Merge, Heap Sort).
- **Step 4**: Master Dynamic Programming and Recursion.
- **Step 5**: Understand Graph algorithms (BFS, DFS, Dijkstra's Shortest Path).
### 📚 Recommended Resources:
- 📺 [Watch Complete Algorithms Course on YouTube](https://www.youtube.com/watch?v=0IAPZzGSbME)
- 📝 [GeeksforGeeks Algorithms Guide](https://www.geeksforgeeks.org/fundamentals-of-algorithms/)
- 📖 [Visualizations of Algorithms](https://visualgo.net/en)
- 💻 [LeetCode Algorithm Practice](https://leetcode.com/)
""",
    "machine learning": """
### 🗺️ Machine Learning Roadmap:
- **Step 1**: Master Linear Algebra, calculus, and basic statistics.
- **Step 2**: Learn Python data libraries: NumPy, Pandas, Matplotlib, Seaborn.
- **Step 3**: Master Supervised Learning (Regression, Classification, SVM, Decision Trees).
- **Step 4**: Learn Unsupervised Learning (K-Means Clustering, PCA).
- **Step 5**: Learn Scikit-Learn library and model validation metrics.
### 📚 Recommended Resources:
- 📺 [Watch Complete Machine Learning Course on YouTube](https://www.youtube.com/watch?v=JxgmHe2NyeY)
- 📝 [Scikit-Learn Official Tutorials documentation](https://scikit-learn.org/stable/user_guide.html)
- 📖 [GeeksforGeeks ML Notes](https://www.geeksforgeeks.org/machine-learning/)
- 💻 [Kaggle Practice Datasets](https://www.kaggle.com/)
""",
    "ml": """
### 🗺️ Machine Learning Roadmap:
- **Step 1**: Master Linear Algebra, calculus, and basic statistics.
- **Step 2**: Learn Python data libraries: NumPy, Pandas, Matplotlib, Seaborn.
- **Step 3**: Master Supervised Learning (Regression, Classification, SVM, Decision Trees).
- **Step 4**: Learn Unsupervised Learning (K-Means Clustering, PCA).
- **Step 5**: Learn Scikit-Learn library and model validation metrics.
### 📚 Recommended Resources:
- 📺 [Watch Complete Machine Learning Course on YouTube](https://www.youtube.com/watch?v=JxgmHe2NyeY)
- 📝 [Scikit-Learn Official Tutorials documentation](https://scikit-learn.org/stable/user_guide.html)
- 📖 [GeeksforGeeks ML Notes](https://www.geeksforgeeks.org/machine-learning/)
- 💻 [Kaggle Practice Datasets](https://www.kaggle.com/)
""",
    "deep learning": """
### 🗺️ Deep Learning Roadmap:
- **Step 1**: Understand Neural Networks basics (Perceptron, Activation Functions).
- **Step 2**: Learn Backpropagation, loss functions, and optimization algorithms.
- **Step 3**: Master Convolutional Neural Networks (CNNs) for image processing.
- **Step 4**: Master Recurrent Neural Networks (RNNs) and LSTMs for sequences.
- **Step 5**: Learn deep learning frameworks (TensorFlow, PyTorch).
### 📚 Recommended Resources:
- 📺 [Watch Complete Deep Learning Course on YouTube](https://www.youtube.com/watch?v=d2kxUVwWWwU)
- 📝 [Deep Learning Book by Goodfellow Reference](https://www.deeplearningbook.org)
- 📖 [GeeksforGeeks Deep Learning Notes](https://www.geeksforgeeks.org/deep-learning-tutorial/)
- 💻 [Kaggle Deep Learning Practice](https://www.kaggle.com/learn/deep-learning)
""",
    "ai": """
### 🗺️ Artificial Intelligence Roadmap:
- **Step 1**: Learn basic AI concepts, search strategies, and logic agents.
- **Step 2**: Understand probabilistic reasoning and state models.
- **Step 3**: Learn core Machine Learning and NLP concepts.
- **Step 4**: Understand neural network architectures and reinforcement learning.
- **Step 5**: Practice implementing simple agents and logic networks.
### 📚 Recommended Resources:
- 📺 [Watch Artificial Intelligence Course on YouTube](https://www.youtube.com/watch?v=JMUxmLyrhSk)
- 📝 [Stanford AI Course Notes & Material](http://web.stanford.edu/class/cs221/)
- 📖 [GeeksforGeeks AI Notes](https://www.geeksforgeeks.org/artificial-intelligence-an-introduction/)
- 💻 [AIMA Python Code Implementations GitHub](https://github.com/aimacode/aima-python)
""",
    "ui/ux": """
### 🗺️ UI/UX Design Roadmap:
- **Step 1**: Learn design principles (contrast, balance, hierarchy, colors).
- **Step 2**: Understand User Research, User Personas, and User Journey mapping.
- **Step 3**: Master Wireframing and Information Architecture.
- **Step 4**: Master Prototyping, usability testing, and design systems.
- **Step 5**: Understand accessibility standards (WCAG guidelines).
### 📚 Recommended Resources:
- 📺 [Watch Complete UI/UX Design Course on YouTube](https://www.youtube.com/watch?v=uQsyobT2Rv8)
- 📝 [Nielsen Norman Group UX Articles Reference](https://www.nngroup.com/articles/)
- 📖 [Google UX Design Certificate Notes](https://grow.google/certificates/ux-design/)
- 💻 [Material Design Systems Guidelines](https://m3.material.io)
""",
    "figma": """
### 🗺️ Figma Roadmap:
- **Step 1**: Master Figma interface, frame configurations, and vector tools.
- **Step 2**: Learn Auto Layout, constraints, and responsive design configs.
- **Step 3**: Master Components, Variants, and properties.
- **Step 4**: Create interactive prototyping, micro-interactions, and smart animate.
- **Step 5**: Learn how to structure design handoffs and inspect code properties.
### 📚 Recommended Resources:
- 📺 [Watch Figma Prototyping Course on YouTube](https://www.youtube.com/watch?v=uQsyobT2Rv8)
- 📝 [Official Figma Help Guide](https://help.figma.com/hc/en-us)
- 📖 [Figma Best Practices Notes](https://www.figma.com/best-practices/)
- 💻 [Figma Community Design Files & Kits](https://www.figma.com/community)
""",
    "cloud": """
### 🗺️ Cloud Computing Roadmap:
- **Step 1**: Understand Cloud architectures: IaaS, PaaS, SaaS, and hybrid models.
- **Step 2**: Learn virtualization, resource groups, and networks configurations.
- **Step 3**: Learn Google Cloud (GCP) console, VMs, and Cloud Run services.
- **Step 4**: Master AWS Cloud fundamentals (EC2, S3, IAM policies).
- **Step 5**: Understand serverless services and cloud scalability concepts.
### 📚 Recommended Resources:
- 📺 [Watch Cloud Computing Course on YouTube](https://www.youtube.com/watch?v=2LaAJq1lB1Q)
- 📝 [AWS Cloud Fundamentals Documentation Guide](https://docs.aws.amazon.com)
- 📖 [GeeksforGeeks Cloud Computing Notes](https://www.geeksforgeeks.org/cloud-computing/)
- 💻 [Google Cloud Skills Boost](https://www.cloudskillsboost.google/)
""",
    "devops": """
### 🗺️ DevOps Roadmap:
- **Step 1**: Master Linux administration, shell scripting, and command line tools.
- **Step 2**: Understand CI/CD pipelines (GitHub Actions, GitLab, or Jenkins).
- **Step 3**: Master Containerization basics (Docker networks, volumes, Dockerfile).
- **Step 4**: Learn Infrastructure as Code (IaC) - Terraform configurations.
- **Step 5**: Understand container orchestration with Kubernetes and log monitor tools.
### 📚 Recommended Resources:
- 📺 [Watch DevOps Training Course on YouTube](https://www.youtube.com/watch?v=hQcFE0RD0cQ)
- 📝 [DevOps Interactive Roadmap Resource](https://roadmap.sh/devops)
- 📖 [GeeksforGeeks DevOps Notes](https://www.geeksforgeeks.org/devops-tutorial/)
- 💻 [Awesome DevOps Tools List GitHub](https://github.com/dastergon/awesome-devops)
""",
    "cyber security": """
### 🗺️ Cybersecurity Roadmap:
- **Step 1**: Understand networking protocols (TCP/IP, DNS, HTTP, SSL).
- **Step 2**: Learn operating system safety rules, permissions, and directory logs.
- **Step 3**: Learn common vulnerabilities and exploits (OWASP Top 10).
- **Step 4**: Practice cryptography concepts (symmetric/asymmetric encryption, hashing).
- **Step 5**: Understand firewalls, network monitoring tools (Wireshark), and threat mitigation.
### 📚 Recommended Resources:
- 📺 [Watch Complete Cybersecurity Course on YouTube](https://www.youtube.com/watch?v=3Kq1MIfTWCE)
- 📝 [OWASP Cheat Sheet Reference Series](https://cheatsheetseries.owasp.org)
- 📖 [GeeksforGeeks Cyber Security Notes](https://www.geeksforgeeks.org/cyber-security-tutorial/)
- 💻 [TryHackMe Cyber Security Practice](https://tryhackme.com/)
"""
  };

  static String _normalize(String skill) {
    return skill.trim().toLowerCase();
  }

  /// Retrieves cached roadmap for a given skill. Checks Memory -> SharedPreferences -> Firestore.
  static Future<String?> getRoadmap(String skill) async {
    final norm = _normalize(skill);

    // 1. Check Pre-populated Database
    if (_prepopulatedRoadmaps.containsKey(norm)) {
      debugPrint("SKILL_CACHE [PRE-POPULATED HIT]: $skill");
      return _prepopulatedRoadmaps[norm];
    }

    // 2. Check Memory Cache
    if (_memoryCache.containsKey(norm)) {
      debugPrint("SKILL_CACHE [MEMORY HIT]: $skill");
      return _memoryCache[norm];
    }

    // 3. Check SharedPreferences (Local Disk)
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVal = prefs.getString("roadmap_$norm");
      if (localVal != null && localVal.isNotEmpty) {
        debugPrint("SKILL_CACHE [LOCAL DISK HIT]: $skill");
        _memoryCache[norm] = localVal; // Cache in memory
        return localVal;
      }
    } catch (e) {
      debugPrint("SKILL_CACHE [LOCAL DISK READ ERROR]: $e");
    }

    // 4. Check Cloud Firestore (Shared Cloud Cache)
    try {
      final doc = await FirebaseFirestore.instance.collection('skill_resources').doc(norm).get();
      if (doc.exists) {
        final roadmap = doc.data()?['roadmap'] as String?;
        if (roadmap != null && roadmap.isNotEmpty) {
          debugPrint("SKILL_CACHE [FIRESTORE HIT]: $skill");
          _memoryCache[norm] = roadmap; // Cache in memory
          
          // Save to SharedPreferences for offline speed next time
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("roadmap_$norm", roadmap);
          
          return roadmap;
        }
      }
    } catch (e) {
      debugPrint("SKILL_CACHE [FIRESTORE READ ERROR]: $e");
    }

    debugPrint("SKILL_CACHE [CACHE MISS]: $skill");
    return null;
  }

  /// Saves a newly generated roadmap to Memory, SharedPreferences, and Firestore.
  static Future<void> saveRoadmap(String skill, String roadmap) async {
    if (roadmap.isEmpty) return;
    final norm = _normalize(skill);

    // Skip saving pre-populated roadmaps
    if (_prepopulatedRoadmaps.containsKey(norm)) return;

    // 1. Save in Memory
    _memoryCache[norm] = roadmap;
    debugPrint("SKILL_CACHE [SAVE MEMORY]: $skill");

    // 2. Save in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("roadmap_$norm", roadmap);
      debugPrint("SKILL_CACHE [SAVE LOCAL DISK]: $skill");
    } catch (e) {
      debugPrint("SKILL_CACHE [LOCAL DISK SAVE ERROR]: $e");
    }

    // 3. Save in Cloud Firestore
    try {
      await FirebaseFirestore.instance.collection('skill_resources').doc(norm).set({
        'roadmap': roadmap,
        'savedAt': FieldValue.serverTimestamp(),
      });
      debugPrint("SKILL_CACHE [SAVE FIRESTORE]: $skill");
    } catch (e) {
      debugPrint("SKILL_CACHE [FIRESTORE SAVE ERROR]: $e");
    }
  }
}
