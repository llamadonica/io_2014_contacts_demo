import 'package:grinder/grinder.dart';
import 'package:redstone/tasks.dart';

main(List<String> args) {
  task('build', Pub.build);
  task('deploy_server', deployServer, ['build']);
  task('all', null, ['build', 'deploy_server']);

  startGrinder(args);
}