
import 'package:flutter/material.dart';
import 'package:peliculasapp/models/models.dart';

class MovieSlider extends StatefulWidget {

  final String title;
  final List<Movie> movies;
  final Function onNextPage;

  MovieSlider({ @required this.movies, this.title, @required this.onNextPage});

  @override
  _MovieSliderState createState() => _MovieSliderState();
}

class _MovieSliderState extends State<MovieSlider> {

  final ScrollController scrollController = new ScrollController();

  /* Inicializa el widget */
  @override
  void initState() {
    super.initState();
    
    /* Listener de nuestro ScrollController */
    scrollController.addListener(() {

      if ( scrollController.position.pixels >= scrollController.position.maxScrollExtent - 500 ) {
        widget.onNextPage();
      }

    });
  }


  /* Destruye el widget */
  @override
  void dispose() {
    
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 255,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if( widget.title != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20
              ),
              child: Text( widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                )
              )
            ),

          SizedBox(
            height: 5,
          ),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: widget.movies.length,
              itemBuilder: (_, int index) => _MoviePoster(widget.movies[index])
              
            )
          )

        ],
      )
    );
  }
}



class _MoviePoster extends StatelessWidget {

  final Movie movie;

  _MoviePoster(this.movie);

  @override
  Widget build(BuildContext context) {

    movie.heroId = 'populares-${movie.id}';

    return Container(
      width: 130,
      height: 190,
      margin: EdgeInsets.symmetric(
        horizontal: 10
      ),
      child: Column(
        children: [

          GestureDetector(
            onTap: () => Navigator.pushNamed(context, 'details', arguments: movie ),
            child: Hero(
              tag: movie.heroId,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeInImage(
                  placeholder: AssetImage('assets/no-image.jpg'),
                  image: NetworkImage( movie.fullPosterImg ),
                  width: 130,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 5,
          ),

          Text( movie.title ,
            overflow: TextOverflow.ellipsis, 
            maxLines: 2,
            textAlign: TextAlign.center
          )
        ]
      )
    );
  }
}