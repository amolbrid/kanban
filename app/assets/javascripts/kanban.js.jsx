/** @jsx React.DOM */

// http://tobiasahlin.com/spinkit/
var Spinner = React.createClass({
  render: function() {
    return (
      <div className="spinner">
        <div className="rect1"></div>
        <div className="rect2"></div>
        <div className="rect3"></div>
        <div className="rect4"></div>
        <div className="rect5"></div>
      </div>
    );
  }
});

var AppMenu = React.createClass({
  render: function() {
    return(
      <div className="dropdown pull-left">
        <a id="dLabel" role="button" data-toggle="dropdown" data-target="#" href="" className="btn toolbar-button">
          <i className="fa fa-bars"></i>
        </a>

        <ul className="dropdown-menu" role="menu" aria-labelledby="dLabel">
          <li>
            <a href=""><i className="fa fa-edit"/>&nbsp;Edit Board</a>
          </li>
          <li className="divider"></li>
          <li><a href=""><i className="fa fa-plus"/>&nbsp;Create Board</a></li>
          <li className="divider"></li>
          <li><strong>&nbsp;&nbsp;Boards</strong></li>
          <li><a href="">Board 1</a></li>
          <li><a href="">Board 2</a></li>
          <li><a href="">Board 3</a></li>
        </ul>
      </div>
    );
  }
});

var TypeProgress = React.createClass({
  componentDidMount: function() {
    this._addBootstrapTooltip();
  },

  componentWillUnmount: function() {
    $(this.getDOMNode()).tooltip('destroy');
  },

  componentDidUpdate: function() {
    this._addBootstrapTooltip();
  },

  onClick: function(e) {
    //TODO
  },

  _addBootstrapTooltip: function() {
    $(this.getDOMNode()).find('[title]').tooltip({placement: 'bottom'});
  },

  render: function() {
    var labelsCount = {},
      labelsColor = {},
      totalCount = 0;

    this.props.data.forEach(function(stage) {
      stage.cards.forEach(function(card) {
        card.labels.forEach(function(label) {
          if(label.name.indexOf("type:") == 0) {
            var count = labelsCount[label.name] || 0;
            labelsCount[label.name] = ++count;
            labelsColor[label.name] = label.color;
            totalCount++;
          }
        });
      });
    });

    var tuples = [];
    for (var key in labelsCount) tuples.push([key, labelsCount[key]]);
    tuples.sort(function(a, b) {
      a = a[1];
      b = b[1];

      return a > b ? -1 : (a < b ? 1 : 0);
    });

    var progress = [];
    tuples.forEach(function(tuple) {
      var val = tuple[1],
        key = tuple[0],
        width = ((val / totalCount) * 100).toFixed(2) + "%",
        bgColor = labelsColor[key],
        title = key + " [" + val + "]" + " (" + width + ") ";

      progress.push(
        <div key={key} className="progress-bar" style={{width: width, backgroundColor: "#"+bgColor, cursor: "pointer"}}
        title={title}>
          <span>{title}</span>
        </div>
      );
    });

    if(progress.length > 0) {
      return (
        <div className="progress type-progress" onClick={this.onClick}>
          {progress}
        </div>
      );
    } else {
      return (<div></div>);
    }
  }
});

var Search = React.createClass({
  componentDidMount: function() {
    Mousetrap.bind('/', this._setFocusOnSearchBox);
  },

  componentWillUnmount: function() {
    Mousetrap.unbind('/');
  },

  render: function() {
    return (
      <input
        ref="searchBox"
        type="text"
        className="form-control search-box"
        onChange={_.throttle(this._handleChange,100)}
        placeholder="Search issue by title or id..."></input>
    );
  },

  _setFocusOnSearchBox: function() {
    this.refs.searchBox.getDOMNode().focus();
    return false;
  },

  _handleChange: function(e) {
    this.props.searchHandler(e.target.value);
  }
});

var Assignee = React.createClass({
  componentDidMount: function() {
    this._addBootstrapTooltip();
  },

  componentWillUnmount: function() {
    $(this.getDOMNode()).tooltip('destroy');
  },

  componentDidUpdate: function() {
    this._addBootstrapTooltip();
  },

  render: function() {
    var className = this.props.selectedAssignee.length > 0 ? "gray-scale" : "";
    if(this.props.name === this.props.selectedAssignee) {
      className = "selected";
    }

    return (
      <span className="member" rel="tooltip" title={this.props.name}>
        <img src={this.props.avatar_url} className={className} onClick={this._handleClick}></img>
      </span>
    );
  },

  _addBootstrapTooltip: function() {
    $(this.getDOMNode()).tooltip({placement: 'top'});
  },

  _handleClick: function() {
    this.props.clickHandler(this.props.name);
  }
});

var Card = React.createClass({
  componentDidMount: function() {
    this._addBootstrapTooltip();
  },

  componentWillUnmount: function() {
    this._removeBootstrapTooltip();
  },

  componentDidUpdate: function() {
    this._addBootstrapTooltip();
  },

  onDragStart: function(e) {
    this.props.handleDragStart(e);
  },

  onDragEnd: function(e) {
    this.props.handleDragEnd(e);
  },

  onErrorClick: function(e) {
    this.props.card["error"] = undefined;
    this._removeBootstrapTooltip();
    this.forceUpdate();
  },

  _addBootstrapTooltip: function() {
    $(this.getDOMNode()).find('[title]').tooltip({placement: 'top', container: 'body'});
  },

  _removeBootstrapTooltip: function() {
    $(this.getDOMNode()).find('[title]').tooltip('destroy');
  },

  render: function() {
    var labelColors = [],
      labels = [],
      cardError,
      isBlocker = false;

    this.props.card.labels.forEach(function(label) {
      labelColors.push(<span key={label.name} className="label-color" style={{backgroundColor: '#' + label.color}}/>);
      labels.push(label.name);
      if(label.name === 'blocker') isBlocker = true;
    });

    if(this.props.card.error) {
      cardError = <div className="card-error" onClick={this.onErrorClick} title="Click to hide">
                    <i className="fa fa-exclamation-circle"></i>&nbsp;{this.props.card.error}</div>;
    }

    var classes;
    if(isBlocker) {
      classes = "card card-blocker";
    } else {
      classes = "card card-default";
    }

    return (
      <div className={classes}
            id={this.props.card.number}
            draggable="true"
            onDragEnd={this.onDragEnd}
            onDragStart={this.onDragStart}>
        <div className="card-header">
          <span>
            <img src={this.props.card.assignee_avatar_url ? this.props.card.assignee_avatar_url : ''} width='20' height='20'/>
            {this.props.card.assignee ? this.props.card.assignee : 'NA'}
          </span>
          <div className="pull-right">
            <span className={this.props.card.is_pull_request ? "octicon octicon-git-pull-request" : ''}></span>
            <a href={this.props.card.html_url} target="_blank">&#35;{this.props.card.number}</a>
          </div>
        </div>
        <div className="card-title">
          {this.props.card.title}
        </div>
        <div className="card-footer">
          <div className="card-label">
            <span title={labels.join(', ')} rel="tooltip">
              {labelColors}
            </span>
          </div>
          {cardError}
        </div>
      </div>
    );
  }
});

var Stage = React.createClass({
  dragOver: function(e) {
    this.props.handleDragOver(e);
  },

  render: function() {
    var cards=[];

    var sortedCards = this.props.data.cards.sort(function(a, b){
      return a.number - b.number;
    });

    sortedCards.forEach(function(card, index) {
      var assigneeFilter = (this.props.selectedAssignee === ""
                              || this.props.selectedAssignee === card.assignee);
      var searchTextFilter = (this.props.searchText === ""
                              || this.props.searchText == card.number
                              || card.title.toLowerCase().indexOf(this.props.searchText) > -1);
      var key = card.number + "-" + this.props.data.id + "-" + index;
      if(assigneeFilter && searchTextFilter) {
        cards.push(<Card
                        key={key}
                        card={card}
                        handleDragEnd={this.props.handleDragEnd}
                        handleDragStart={this.props.handleDragStart}/>);
      }
    }.bind(this));

    return (
      <div className="board-stage" id={this.props.data.id}>
        <div className="stage-header">
          <h5>
            {this.props.data.name}
            <span className="card-count pull-right">{cards.length}</span>
          </h5>
        </div>
        <div className="stage-cards">
          {cards}
        </div>
      </div>
    );
  }
});

var Board = React.createClass({
  getInitialState: function() {
    return {
      data: {name: ""},
      assignee: "",
      searchText: "",
      loading: true,
      forceSync: ''
    };
  },

  componentDidMount: function() {
    this._loadCards();
    this._addBootstrapTooltip();
  },

  componentWillUnmount: function() {
    $(this.getDOMNode()).tooltip('destroy');
  },

  componentDidUpdate: function() {
    this._addBootstrapTooltip();
  },

  _addBootstrapTooltip: function() {
    $(this.getDOMNode()).find('[rel=tooltip-left]').tooltip({placement: 'left'});
  },

  dragStart: function(e) {
    console.log("drag start");
    this.dragged = e.currentTarget;
    e.dataTransfer.effectAllowed = 'move';

    // Firefox requires calling dataTransfer.setData
    // for the drag to properly work
    e.dataTransfer.setData("text/html", e.currentTarget);
  },

  dragEnd: function(e) {
    this.dragged.style.display = "block";

    if(!this.over) return;
    this.over.style.backgroundColor = "#F3F3F3";

    if(this.dragged.parentNode.parentNode.id == this.over.id) return;

    console.log("card: " + this.dragged.id + ", source: " + this.dragged.parentNode.parentNode.id + ", target: " + this.over.id);
    this.handleDragDrop(this.dragged.id, this.over.id, this.dragged.parentNode.parentNode.id);
  },

  dragOver: function(e) {
    e.preventDefault();
    this.dragged.style.display = "none";

    var targetBound = e.target.getBoundingClientRect();

    var foundStage = undefined;
    var stages = document.getElementsByClassName('board-stage');
    for(var index = 0; index < stages.length; index++) {
      var stage = stages.item(index);
      stage.style.backgroundColor = "#F5F5F5";
      var bound = stage.getBoundingClientRect();
      if(targetBound.top >= bound.top
          && targetBound.left >= bound.left
          && targetBound.top <= (bound.top + bound.height)
          && targetBound.left <= (bound.width + bound.left)) {
        foundStage = stage;
        // break;
      }
    }

    if(foundStage) {
      this.over = foundStage;
      foundStage.style.backgroundColor = "#b6b6b6";
      // console.log("stage found");
    } else {
      this.over = undefined;
      // console.log("stage not found");
    }
  },

  handleDragDrop: function(cardId, targetStageId, senderStageId) {
    var targetStage, senderStage;
    this.state.data.stages.forEach(function(stage){
      if(stage.id == targetStageId) {
        targetStage = stage;
      } else if(stage.id == senderStageId) {
        senderStage = stage;
      }
    });

    var indexToRemove = -1;
    var cardToMove = undefined;
    senderStage.cards.forEach(function(card, index) {
      if(card.number == cardId) {
        cardToMove = card;
        card.stage = targetStage;
        targetStage.cards.push(card);
        indexToRemove = index;
      }
    });

    if(indexToRemove > -1) {
      senderStage.cards.splice(indexToRemove, 1);
    }
    // console.log("sender: " + senderStage.cards.map(function(card) { return card.number }));
    // console.log("target: " + targetStage.cards.map(function(card) { return card.number }));

    this.setState(_.merge(this.state, {data: this.state.data}));

    var url = window.APP_URLS.MOVE_CARD,
      data = "number=" + cardToMove.number +
        "&next_stage=" + targetStage.github_label +
        "&prev_stage=" + senderStage.github_label +
        "&repo_url=" + cardToMove.repo_url;

    $.ajax({
      url: url,
      type: 'POST',
      data: data,
      success: function(data) {

      }.bind(this),
      error: function(xhr, status, err) {
        cardToMove["error"] = err.toString();

        cardToMove.stage = senderStage;
        senderStage.cards.push(cardToMove);

        var indexToRemove = -1;
        targetStage.cards.forEach(function(card, index){
          if(card.number == cardToMove.number) {
            indexToRemove = index;
          }
        });

        if(indexToRemove > -1) targetStage.cards.splice(indexToRemove, 1);

        this.setState(_.merge(this.state, {data: this.state.data}));
        console.log(status, err.toString());
      }.bind(this)
    });
  },

  _loadCards: function() {
    $.ajax({
      url: window.APP_URLS.BOARD,
      dataType: 'json',
      success: function(data) {
        var newState = _.merge(this.state, {data: data, loading: false, forceSync: ''});
        this.setState(newState);
      }.bind(this),
      error: function(xhr, status, err) {
        console.log(this.props.url, status, err.toString());
      }.bind(this)
    });
  },

  _handleFilterByAssignee: function(assignee) {
    var name = this.state.assignee === assignee ? "" : assignee;
    var newState = _.merge(this.state, {assignee: name});
    this.setState(newState);
  },

  _handleSearch: function(text) {
    var newState = _.merge(this.state, {searchText: text.toLowerCase()});
    this.setState(newState);
  },

  _onClickSync: function(e) {
    e.preventDefault();
    var newState = _.merge(this.state, {forceSync: 'fa-spin'});
    this.setState(newState);
    this._loadCards();
  },

  render: function() {
    if(this.state.loading) {
      return (<Spinner/>);
    }

    var stages = [],
      assignees = [],
      names = [];

    if(this.state.data.stages) {
      this.state.data.stages.forEach(function(stage, index) {
        stages.push(<Stage key={stage.github_label}
                          data={stage}
                          selectedAssignee={this.state.assignee}
                          searchText={this.state.searchText}
                          handleDragStart={this.dragStart}
                          handleDragEnd={this.dragEnd}
                          handleDragOver={this.dragOver}/>);

        stage.cards.forEach(function(card) {
          if(names.indexOf(card.assignee) === -1) {
            assignees.push(<Assignee key={card.assignee}
              name={card.assignee}
              avatar_url={card.assignee_avatar_url}
              selectedAssignee={this.state.assignee}
              clickHandler={this._handleFilterByAssignee}/>);
            names.push(card.assignee);
          }
        }.bind(this));
      }.bind(this));
    }

    var boardWidth = (250+10) * stages.length;
    var forceSyncStyle = "fa fa-refresh " + this.state.forceSync;

    console.log("rendering...");
    return (
      <div className="container-fluid" onDragOver={this.dragOver}>
        <div className="row app-header-bg">
          <div className="col-sm-6">
            <h4 className="board-name">
              {this.state.data.name}
              <span className="small due-date">&nbsp;&nbsp;Due on {this.state.data.due_date}</span>
            </h4>
          </div>

          <div className="col-sm-5">
            <a href="/boards" className="btn toolbar-button pull-right">
                <i className="fa fa-th-list"/>
                &nbsp;Boards
              </a>

            <div className="button-separator pull-right">
              &nbsp;
            </div>

            <button className="btn pull-right toolbar-button" onClick={this._onClickSync}>
              <i className={forceSyncStyle}/>
              &nbsp;Sync
            </button>

            <a href={window.APP_URLS.EDIT_BOARD} className="btn pull-right toolbar-button">
              <i className="fa fa-edit"/>
              &nbsp;Edit Board
            </a>
          </div>

          <div className="col-sm-1">
            <a href="/signout" className="pull-right" title="Signout" rel="tooltip-left">
              <img className="round-profile-img" src={window.APP_URLS.CURRENT_USER_IMG} width="32" height="32"></img>
            </a>
          </div>
        </div>


        <div className="board-area-header clearfix">
          <div className = "pull-left">
            <Search searchText={this.state.searchText} searchHandler={this._handleSearch}/>
          </div>
          <div className="members pull-right">
            {assignees}
          </div>
        </div>

        <TypeProgress data={this.state.data.stages}/>

        <div className="board-wrapper">
          <div className="board-area" style={{width: boardWidth + "px"}}>
            {stages}
          </div>
          <div className="clearfix"></div>
        </div>
      </div>
    );
  }
});

function renderBoard() {
  React.renderComponent(<Board />, document.getElementById('main-container'));
}
