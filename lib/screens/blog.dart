
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_2208e/widgets/custom_drawer.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});
  static const String routeName = '/BlogPage';


  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {

  late String displayName;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      displayName = user.displayName.toString();
    } else {
      displayName = "Unknown User";
    }
  }

  
  final List<Map<String, String>> blogPosts = [
    {
      'title': 'Top Interior Design Trends of 2024',
      'description': 'Explore the most popular interior design trends this year, from sustainable materials to minimalist aesthetics.',
      'image': 'assets/images/blog1.jpg',
    },
    {
      'title': '5 DIY Home Improvement Projects',
      'description': 'Get your hands dirty with these simple yet effective DIY projects that will transform your living space.',
      'image': 'assets/images/blog2.jpg',
    },
    {
      'title': 'How to Make Small Spaces Feel Bigger',
      'description': 'Learn some clever interior design tricks to maximize space in small apartments or rooms.',
      'image': 'assets/images/blog3.jpg',
    },
    {
      'title': 'Color Palette Ideas for Modern Homes',
      'description': 'Discover the latest color trends to refresh your home decor and bring it up to date.',
      'image': 'assets/images/blog4.jpg',
    },
    {
      'title': 'Budget-Friendly Interior Design Tips',
      'description': 'Designing your dream home doesn’t have to break the bank. Check out these budget-friendly tips for stylish living.',
      'image': 'assets/images/blog5.jpg',
    },
  ];

  
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustNavigationDrawer(
        displayName: displayName,
      ),
      appBar: AppBar(
        title: Text(
          'Blogs and Articles',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: blogPosts.length,
          itemBuilder: (context, index) {
            return BlogPostCard(
              title: blogPosts[index]['title']!,
              description: blogPosts[index]['description']!,
              image: blogPosts[index]['image']!,
            );
          },
        ),
      ),
    );
  }
}

class BlogPostCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  BlogPostCard({
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            image.isNotEmpty ? image : 'assets/default_image.jpg', 
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Text('Image not found'));
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleDetailPage(title: title),
                        ),
                      );
                    },
                    child: Text(
                      'Read More',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy article detail page
class ArticleDetailPage extends StatelessWidget {
  final String title;

  ArticleDetailPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.lightBlue.withOpacity(0.6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'This is a detailed article about "$title". Here you can add more content about this topic, including images, videos, and other multimedia.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
