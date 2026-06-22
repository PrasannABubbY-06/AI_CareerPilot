import '../models/roadmap_model.dart';

class RoadmapService {

  static final List<String> supportedSkills = [
    "flutter",
    "frontend",
    "web",
    "python",
    "ai",
    "ml",
    "machine learning",
    "cyber",
    "security",
    "java",
  ];

  static RoadmapModel? generateRoadmap(String skill) {

    final lowerSkill = skill.toLowerCase().trim();

    // ================= FLUTTER =================

    if (lowerSkill.contains("flutter")) {

      return RoadmapModel(
        skill: "Flutter Developer",

        basics: [
          "Programming Basics",
          "Dart Basics",
          "Variables",
          "Functions",
          "OOP",
          "Async / Await",
        ],

        coreSkills: [
          "Flutter Widgets",
          "State Management",
          "API Integration",
          "Firebase",
          "Authentication",
          "Responsive UI",
          "Animations",
          "Local Storage",
        ],

        beginnerProjects: [
          "Calculator App",
          "Todo App",
          "Weather App",
        ],

        intermediateProjects: [
          "Chat App",
          "Expense Tracker",
          "Notes App",
        ],

        advancedProjects: [
          "AI CareerPilot",
          "Realtime Interview App",
          "E-Commerce App",
        ],

        interviewPrep: [
          "Flutter Interview Questions",
          "Dart OOP Questions",
          "Firebase Questions",
          "HR Questions",
        ],
      );
    }

    // ================= FRONTEND =================

    else if (lowerSkill.contains("frontend") ||
        lowerSkill.contains("web")) {

      return RoadmapModel(
        skill: "Frontend Developer",

        basics: [
          "HTML",
          "CSS",
          "JavaScript",
          "Git & GitHub",
          "Responsive Design",
        ],

        coreSkills: [
          "React JS",
          "API Fetching",
          "Routing",
          "Tailwind CSS",
          "State Management",
          "Deployment",
        ],

        beginnerProjects: [
          "Portfolio Website",
          "Landing Page",
          "Calculator Website",
        ],

        intermediateProjects: [
          "Movie App",
          "Weather App",
          "Task Manager",
        ],

        advancedProjects: [
          "Admin Dashboard",
          "Realtime Chat Website",
          "Full Stack Frontend",
        ],

        interviewPrep: [
          "HTML Questions",
          "CSS Questions",
          "JavaScript Questions",
          "React Questions",
        ],
      );
    }

    // ================= PYTHON =================

    else if (lowerSkill.contains("python")) {

      return RoadmapModel(
        skill: "Python Developer",

        basics: [
          "Python Syntax",
          "Variables",
          "Loops",
          "Functions",
          "OOP",
        ],

        coreSkills: [
          "File Handling",
          "APIs",
          "Automation",
          "Libraries",
          "Database Basics",
        ],

        beginnerProjects: [
          "Calculator",
          "Quiz App",
          "Password Generator",
        ],

        intermediateProjects: [
          "Automation Tool",
          "Web Scraper",
          "GUI App",
        ],

        advancedProjects: [
          "AI Assistant",
          "Data Dashboard",
          "Machine Learning Project",
        ],

        interviewPrep: [
          "Python Basics",
          "OOP Questions",
          "Coding Problems",
        ],
      );
    }

    // ================= AI / ML =================

    else if (lowerSkill.contains("ai") ||
        lowerSkill.contains("ml") ||
        lowerSkill.contains("machine learning")) {

      return RoadmapModel(
        skill: "AI / ML Engineer",

        basics: [
          "Python",
          "Statistics",
          "Linear Algebra",
          "Probability",
        ],

        coreSkills: [
          "Machine Learning",
          "Deep Learning",
          "TensorFlow",
          "Neural Networks",
          "NLP",
          "Computer Vision",
        ],

        beginnerProjects: [
          "Spam Classifier",
          "Image Classifier",
        ],

        intermediateProjects: [
          "Chatbot",
          "Recommendation System",
        ],

        advancedProjects: [
          "Voice Assistant",
          "AI Interview System",
          "AI Resume Analyzer",
        ],

        interviewPrep: [
          "ML Questions",
          "Deep Learning Questions",
          "Python Coding",
        ],
      );
    }

    // ================= CYBER SECURITY =================

    else if (lowerSkill.contains("cyber") ||
        lowerSkill.contains("security")) {

      return RoadmapModel(
        skill: "Cybersecurity",

        basics: [
          "Networking",
          "Linux Basics",
          "Cybersecurity Basics",
          "Operating Systems",
        ],

        coreSkills: [
          "Ethical Hacking",
          "Kali Linux",
          "Penetration Testing",
          "Wireshark",
          "Vulnerability Analysis",
        ],

        beginnerProjects: [
          "Password Checker",
          "Port Scanner",
        ],

        intermediateProjects: [
          "Vulnerability Scanner",
          "Network Monitor",
        ],

        advancedProjects: [
          "Security Monitoring System",
          "Advanced Pen Testing Tool",
        ],

        interviewPrep: [
          "Networking Questions",
          "Linux Questions",
          "Cybersecurity Questions",
        ],
      );
    }

    // ================= JAVA =================

    else if (lowerSkill.contains("java")) {

      return RoadmapModel(
        skill: "Java Developer",

        basics: [
          "Java Basics",
          "Variables",
          "Loops",
          "Functions",
          "OOP",
        ],

        coreSkills: [
          "Collections",
          "Exception Handling",
          "Multithreading",
          "Spring Boot",
          "Database Connectivity",
        ],

        beginnerProjects: [
          "Calculator",
          "Student Management System",
        ],

        intermediateProjects: [
          "Banking System",
          "REST API",
        ],

        advancedProjects: [
          "E-Commerce Backend",
          "Enterprise Application",
        ],

        interviewPrep: [
          "Java OOP Questions",
          "Spring Boot Questions",
          "Coding Problems",
        ],
      );
    }

    // ================= INVALID =================

    return null;
  }
}
