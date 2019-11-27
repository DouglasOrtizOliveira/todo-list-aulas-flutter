import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:todo_list/helpers/task_helper.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/views/task_dialog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> _listatarefas = [];
  TaskHelper _var = TaskHelper();
  bool _carregando = true;
  double _indicador = 0;
  double _porcentagem = 0;
  int _checkTarefas = 0;

  @override
  void initState() {
    super.initState();
    _var.getAll().then((list) {
      setState(() {
        _listatarefas = list;
        _carregando = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          new CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 5.0,
            animation: true,
            percent: _indicador,
            center: new Text(
              "Concluidas",
              style: new TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 8.0,
                  color: Colors.white),
            ),
            backgroundColor: Colors.white,
            progressColor: Colors.green,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          onPressed: _addNewTask),
      body: _buildListaTarefas(),
    );
  }

  Widget _buildListaTarefas() {
    if (_listatarefas.isEmpty) {
      return Center(
        child: _carregando ? CircularProgressIndicator() : Text("Sem tarefas!"),
      );
    } else {
      return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemCount: _listatarefas.length,
        itemBuilder: _buildTaskItemSlidable,
      );
    }
  }

  Widget _buildTaskItem(BuildContext context, int index) {
    final task = _listatarefas[index];
    return CheckboxListTile(
      value: task.isDone,
      title: Text(task.title),
      subtitle: Text('${task.description} ${task.priority}'),
      onChanged: (bool isChecked) {
        setState(() {
          _porcentagem = 1.0 / _listatarefas.length;
          if (isChecked) {
            _checkTarefas++;
            if (_indicador + _porcentagem > 1.0) {
              _indicador = 1.0;
            } else
              _indicador += _porcentagem;
          } else if (isChecked == false) {
            _checkTarefas--;
            if (_checkTarefas == 0) {
              _indicador = 0.0;
            } else if (_indicador - _porcentagem < 0.0) {
              _indicador = 0.0;
            } else
              _indicador -= _porcentagem;
          }
          task.isDone = isChecked;
        });

        _var.update(task);
      },
    );
  }

  Widget _buildTaskItemSlidable(BuildContext context, int index) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildTaskItem(context, index),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Editar',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            _addNewTask(editedTask: _listatarefas[index], index: index);
          },
        ),
        IconSlideAction(
          caption: 'Excluir',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            _deleteTask(deletedTask: _listatarefas[index], index: index);
            if(_indicador - _porcentagem < 0.0){_indicador = 0.0;}
            else
            _indicador -= _porcentagem;
            _checkTarefas--;
          },
        ),
      ],
    );
  }

  Future _addNewTask({Task editedTask, int index}) async {
    final task = await showDialog<Task>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskDialog(task: editedTask);
      },
    );

    if (task != null) {
      setState(() {
        if (index == null) {
          _listatarefas.add(task);
          _var.save(task);
        } else {
          _listatarefas[index] = task;
          _var.update(task);
        }
      });
    }
  }

  void _deleteTask({Task deletedTask, int index}) {
    setState(() {
      _listatarefas.removeAt(index);
    });

    _var.delete(deletedTask.id);

    Flushbar(
      title: "Exclusão de tarefas",
      message: "Tarefa \"${deletedTask.title}\" removida.",
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      mainButton: FlatButton(
        child: Text(
          "Desfazer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          setState(() {
            _listatarefas.insert(index, deletedTask);
            _var.update(deletedTask);
          });
        },
      ),
    )..show(context);
  }
}
