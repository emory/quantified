class DecisionLogsController < ApplicationController
  # GET /decision_logs
  # GET /decision_logs.xml
  def index
    @decision_logs = DecisionLog.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @decision_logs }
    end
  end

  # GET /decision_logs/1
  # GET /decision_logs/1.xml
  def show
    @decision_log = DecisionLog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @decision_log }
    end
  end

  # GET /decision_logs/new
  # GET /decision_logs/new.xml
  def new
    @decision_log = DecisionLog.new
    @decision_log.date = Date.today
    if params[:decision_id] then
      @decision_log.decision_id = params[:decision_id]
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @decision_log }
    end
  end

  # GET /decision_logs/1/edit
  def edit
    @decision_log = DecisionLog.find(params[:id])
  end

  # POST /decision_logs
  # POST /decision_logs.xml
  def create
    @decision_log = DecisionLog.new(params[:decision_log])

    respond_to do |format|
      if @decision_log.save
        format.html { redirect_to(@decision_log, :notice => 'Decision log was successfully created.') }
        format.xml  { render :xml => @decision_log, :status => :created, :location => @decision_log }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @decision_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /decision_logs/1
  # PUT /decision_logs/1.xml
  def update
    @decision_log = DecisionLog.find(params[:id])

    respond_to do |format|
      if @decision_log.update_attributes(params[:decision_log])
        format.html { redirect_to(@decision_log, :notice => 'Decision log was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @decision_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /decision_logs/1
  # DELETE /decision_logs/1.xml
  def destroy
    @decision_log = DecisionLog.find(params[:id])
    @decision_log.destroy

    respond_to do |format|
      format.html { redirect_to(decision_logs_url) }
      format.xml  { head :ok }
    end
  end
end
