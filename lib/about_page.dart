import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/banner_image.jpg'), // Replace with your image path
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "How MentSpec Works",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "We are a group of talented and skilled professionals with expertise in various fields. Our mission is to provide exceptional service to our clients while promoting sustainable development.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.0),
                  Text(
                    "Instant Payment Transfer Saves You Time",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "Lorem ipsum dolor sit, amet consectetur adipisicing elit. Quibusdam mollitia laborum non nostrum ut numquam doloribus deleniti vitae repellendus a quas cupiditate neque impedit amet distinctio enim, facere quod omnis id! Quidem maxime dolor hic beatae provident fuga aliquam rem recusandae nemo velit corrupti impedit, adipisci ullam, voluptate iusto optio perferendis dolores animi excepturi repudiandae deserunt! Necessitatibus consequatur eligendi quod pariatur tenetur? Eum quos atque sit aliquid accusamus ratione quia aperiam, nam reprehenderit consectetur neque consequuntur esse inventore dolores voluptatibus adipisci quas, qui, fugit quaerat quidem vero expedita nemo? Non in debitis aspernatur beatae repellendus incidunt consequuntur, pariatur aliquid nostrum. Inventore et, possimus dicta deserunt asperiores magni voluptatibus blanditiis fugiat quis! sit amet consectetur adipisicing elit. Mollitia, quae. Consequatur temporibus qui deserunt rem! Nesciunt accusamus voluptatem perspiciatis doloribus nulla necessitatibus architecto quam, recusandae delectus, aliquid dolorum minus magnam sed voluptates fugiat eaque, optio vero error. Modi consequatur incidunt corrupti labore totam facilis, provident et quidem exercitationem mollitia, numquam ex? Rerum in officiis est ipsa autem magnam vero modi, iure voluptas, reiciendis eum illo. Magni, vero. Ab, deleniti ut, dolor quas, ea reprehenderit inventore illo quo nemo aperiam et molestiae. Nesciunt consequuntur velit iste quo! Quo, iure, odio minus molestiae ipsa soluta voluptates numquam sequi laudantium voluptate neque quod.",
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "OUR VISION",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "Tempora sequi aliquam possimus culpa impedit veritatis delectus, molestias modi temporibus? Modi voluptate illo atque, necessitatibus corrupti corporis soluta eum maxime, provident vero suscipit eaque architecto. Quidem atque quam repellat nemo voluptatum delectus, voluptatem totam asperiores provident praesentium beatae culpa ratione voluptates laborum quibusdam aliquid esse eum natus error debitis rerum voluptate ipsa. Aliquid aut, similique explicabo enim quia, corrupti reprehenderit laborum quis non molestias quam nulla ea eveniet. Delectus, quidem blanditiis ducimus, ipsa odio repellat quo voluptas nesciunt dolorum perferendis suscipit vitae quia, aspernatur sed cumque debitis fugit. Autem, dignissimos!ipsum dolor sit amet consectetur adipisicing elit. Nulla voluptas ad, cumque veritatis reprehenderit dolor cum expedita libero a blanditiis voluptate similique necessitatibus esse, aut id mollitia sunt explicabo aliquid aliquam ea molestias nisi accusamus quia. Harum, nemo. Rerum fugiat cum earum, voluptas incidunt modi quas nulla labore maxime! Itaque dolores fugit doloremque et optio quibusdam dignissimos reprehenderit error quaerat. Reiciendis placeat vel, nobis possimus, optio sint harum maxime deleniti, commodi fugiat odio odit. Reprehenderit necessitatibus eaque qui vel? Recusandae culpa, veniam doloribus aut eaque corporis, architecto dolores perspiciatis quis fuga expedita iste, labore et inventore aperiam vero molestias sed.",
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
