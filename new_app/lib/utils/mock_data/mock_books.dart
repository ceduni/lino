import 'package:Lino_app/models/book_model.dart';

List<Book> mockBooks = [
  Book(
    isbn: '9780132350884',
    qrCodeId: 'QR001',
    title: 'Clean Code: A Handbook of Agile Software Craftsmanship',
    authors: ['Robert C. Martin'],
    description:
        'Even bad code can function. But if code isn’t clean, it can bring a development organization to its knees.',
    coverImage: 'https://example.com/clean_code.jpg',
    publisher: 'Prentice Hall',
    categories: ['Software Development', 'Agile'],
    parutionYear: 2008,
    pages: 464,
    takenHistory: [],
    givenHistory: [],
    dateLastAction: DateTime.now(),
  ),
  Book(
    isbn: '9780201616224',
    qrCodeId: 'QR002',
    title: 'Design Patterns: Elements of Reusable Object-Oriented Software',
    authors: ['Erich Gamma', 'Richard Helm', 'Ralph Johnson', 'John Vlissides'],
    description:
        'Capturing a wealth of experience about the design of object-oriented software, four top-notch designers present a catalog of simple and succinct solutions to commonly occurring design problems.',
    coverImage: 'https://example.com/design_patterns.jpg',
    publisher: 'Addison-Wesley Professional',
    categories: ['Software Development', 'Design Patterns'],
    parutionYear: 1994,
    pages: 395,
    takenHistory: [],
    givenHistory: [],
    dateLastAction: DateTime.now(),
  ),

  Book(
    isbn: '9780137081073',
    qrCodeId: 'QR004',
    title: 'The Clean Coder: A Code of Conduct for Professional Programmers',
    authors: ['Robert C. Martin'],
    description:
        'The Clean Coder describes the journey to professionalism...and it does it with a passion. The Clean Coder describes the principles, patterns, and practices of writing clean code.',
    coverImage: 'https://example.com/clean_coder.jpg',
    publisher: 'Prentice Hall',
    categories: ['Software Development', 'Professional Programming'],
    parutionYear: 2011,
    pages: 256,
    takenHistory: [],
    givenHistory: [],
    dateLastAction: DateTime.now(),
  ),

  Book(
    isbn: '9780321125217',
    qrCodeId: 'QR005',
    title: 'Domain-Driven Design: Tackling Complexity in the Heart of Software',
    authors: ['Eric Evans'],
    description:
        'In this book, Eric Evans describes sophisticated techniques to design and implement a Domain-Driven Design in software projects.',
    coverImage: 'https://example.com/domain_driven_design.jpg',
    publisher: 'Addison-Wesley Professional',
    categories: ['Software Development', 'Design'],
    parutionYear: 2003,
    pages: 560,
    takenHistory: [],
    givenHistory: [],
    dateLastAction: DateTime.now(),
  ),

  Book(
    isbn: '9780201485677',
    qrCodeId: 'QR006',
    title: 'Refactoring: Improving the Design of Existing Code',
    authors: [
      'Martin Fowler',
      'Kent Beck',
      'John Brant',
      'William Opdyke',
      'Don Roberts'
    ],
    description:
        'As the application of object technology--particularly the Java programming language--has become commonplace, a new problem has emerged to confront the software development community.',
    coverImage: 'https://example.com/refactoring.jpg',
    publisher: 'Addison-Wesley Professional',
    categories: ['Software Development', 'Refactoring'],
    parutionYear: 1999,
    pages: 431,
    takenHistory: [],
    givenHistory: [],
    dateLastAction: DateTime.now(),
  ),

  Book(
    isbn: '9780131103627',
    qrCodeId: 'QR007',
    title: 'The C Programming Language',
    authors: ['Brian W. Kernighan', 'Dennis M. Ritchie'],
    description:
        'The authors present the complete guide to ANSI standard C language programming. Written by the developers of C, this new version helps readers keep up with the finalized ANSI standard for C while showing how to take advantage of C’s rich set of operators, economy of expression, improved control flow, and data structures.',
    coverImage: 'https://example.com/c_programming_language.jpg',
    publisher: 'Prentice Hall',
    categories: ['Programming', 'C Language'],
    parutionYear: 1988,
    pages: 272,
    takenHistory: [],
    givenHistory: [],
    dateLastAction: DateTime.now(),
  ),

  Book(
    isbn: '9780134685991',
    qrCodeId: 'QR008',
    title: 'Effective Java',
    authors: ['Joshua Bloch'],
    description:
        'The Definitive Guide to Java Platform Best Practices–Updated for Java 9. Effective Java, Third Edition, brings together seventy-eight indispensable programmer’s rules of thumb: working, best-practice solutions for the programming challenges you encounter every day.',
    coverImage: 'https://example.com/effective_java.jpg',
    publisher: 'Addison-Wesley Professional',
    categories: ['Programming', 'Java'],
    parutionYear: 2018,
    pages: 412,
    takenHistory: [],
    givenHistory: [],
    dateLastAction: DateTime.now(),
  ),
  // Add more mock data entries here...
];
