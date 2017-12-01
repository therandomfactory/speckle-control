#define SAVEPOINT (0)
#define RECURSE   (1)
#define STARTAG   (19)
#define MEASTAG   (18)

#define DEFAULTNAME "a point"
#define NO_CABLE_CHECK (1)

struct plate_coords{
  double x;
  double y;
};

struct aPoint{
  double x;
  double y;
};

struct rotPoint{
  struct rotPoint *nextPoint;
  int    id;
  char   pointName[32];
  struct aPoint starLoc;
  struct aPoint measLoc;
};

struct rotPair{
  struct rotPair *nextPair;
  int    id;
  char   pairName[128];
  struct rotPoint *point1;
  struct rotPoint *point2;
  double rotAngle;
  double rSep2;
};

struct rotStats{
  struct rotPoint *nextPoint;
  struct rotPair  *nextPair;
  int    numberOfPairs;
  double sumAngles;
  double sumWeights;
  double workingAngle;
  double aveAngle;
  double defaultAngle;
};


  
