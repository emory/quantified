class ContextsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :start]
  # GET /contexts
  # GET /contexts.xml
  def index
    authorize! :view_contexts, current_account
    @user = current_account
    @contexts = current_account.contexts.order('name')
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contexts }
    end
  end

  # GET /contexts/1
  # GET /contexts/1.xml
  def show
    @context = current_account.contexts.find(params[:id])
    authorize! :start, @context
    redirect_to start_context_path(params[:id])
  end

  # GET /contexts/new
  # GET /contexts/new.xml
  def new
    authorize! :create, Context
    @context = Context.new
    5.times do @context.context_rules.build end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @context }
    end
  end

  # GET /contexts/1/edit
  def edit
    @context = current_account.contexts.find(params[:id])
    5.times do @context.context_rules.build end
    authorize! :update, @context
  end

  # POST /contexts
  # POST /contexts.xml
  def create
    authorize! :create, Context
    # Change context_rules_attributes to stuff and locations
    rules = params[:context].delete :context_rules_attributes if params[:context] 
    @context = current_account.contexts.new(params[:context])
    if rules
      rules.each do |k, v|
        next if v['stuff'].blank? or v['location'].blank?
        stuff = @account.stuff.find_or_create_by_name(v['stuff'])
        location = @account.get_location(v['location'])
        @context.context_rules.build(:stuff => stuff, :location => location)
      end
    end
    respond_to do |format|
      if @context.save
        format.html { redirect_to(@context, :notice => 'Context was successfully created.') }
        format.xml  { render :xml => @context, :status => :created, :location => @context }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @context.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contexts/1
  # PUT /contexts/1.xml
  def update
    @context = current_account.contexts.find(params[:id])
    authorize! :update, @context
    rules = params[:context][:context_rules_attributes] if params[:context] 
    if rules
      rules.each do |k, v|
        if v['stuff'].blank? or v['location'].blank?
          params[:context][:context_rules_attributes][k]['_destroy'] = 1
        else
          location = @account.get_location(v['location'])
          stuff = @account.stuff.find_by_name(v['stuff'])
          if stuff.nil?
            stuff = @account.stuff.create(:name => v['stuff'], :location => location, :home_location => location, :status => 'active', :stuff_type => 'stuff')
          end
          params[:context][:context_rules_attributes][k]['stuff'] = stuff
          params[:context][:context_rules_attributes][k]['location'] = location
        end
      end
    end
    logger.info "New context rules attributes " + params[:context][:context_rules_attributes].inspect
    respond_to do |format|
      if @context.update_attributes(params[:context])
        format.html { redirect_to(@context, :notice => 'Context was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @context.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contexts/1
  # DELETE /contexts/1.xml
  def destroy
    @context = current_account.contexts.find(params[:id])
    authorize! :delete, @context
    @context.destroy

    respond_to do |format|
      format.html { redirect_to(contexts_url) }
      format.xml  { head :ok }
    end
  end

  def start
    # Parse the list of items in this context
    @context = current_account.contexts.find(params[:id])
    authorize! :start, @context
    @in_place = @context.context_rules.in_place
    @out_of_place = @context.context_rules.out_of_place
  end

  def complete
    authorize! :manage_account, current_account
    @context = current_account.contexts.find(params[:id])
    @context.context_rules.out_of_place.each do |r|
      r.stuff.update_attributes(:location => r.location)
    end
    go_to stuff_index_path, :notice => "Context marked complete."
  end
end
