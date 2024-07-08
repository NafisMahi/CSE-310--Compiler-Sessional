class SymbolInfo{
private:
    string Name;
    string Type;
public:
    SymbolInfo *next;
    SymbolInfo(const string &name, const string &type) : Name(name), Type(type), next(nullptr) {}

    ~SymbolInfo()
    {
        delete next;
    }

    string getName() const {
        return Name;
    }

    string getType() const {
        return Type;
    }

    void printSymbolInfoObject(FILE *file)
    {
       // cout<<"<"<<Name<<","<<Type<<">";
        fprintf(file,"<%s,%s>",Name.c_str(),Type.c_str());
    }

};

class ScopeTable{
private:
    int bucketSize;
    string ID;
public:
    SymbolInfo **scopeTable;
    ScopeTable *parentScope;
    int childrenCount;

    ScopeTable(int n)
    {
        scopeTable=new SymbolInfo*[n];
        for(int i=0;i<n;i++)
        {
            *(scopeTable+i)=nullptr;
        }
        bucketSize=n;
        parentScope= nullptr;
        childrenCount=0;
        ID="1";
    }

    ScopeTable(int n,ScopeTable *parent)
    {
        scopeTable=new SymbolInfo*[n];
        for(int i=0;i<n;i++)
        {
            *(scopeTable+i)=nullptr;
        }
        bucketSize=n;
        parentScope=parent;
        childrenCount=0;
        ID=parentScope->ID+"."+to_string(parentScope->childrenCount);
        //cout<<"Scope table with ID "<<ID<<" created"<<endl;
    }

    ~ScopeTable()
    {
        //cout<<"Scope table with ID "<<ID<<" is removed"<<endl;
        //cout<<"Destroying the current table"<<endl;
        if(ID=="1")
        {
          //  cout<<"Destroying the first scope"<<endl;
        }
        for(int i=0;i<bucketSize;i++)
        {
            delete *(scopeTable+i);
        }
        delete [] scopeTable;
    }

    int getBucketSize()  {
        return bucketSize;
    }

    string getId()  {
        return ID;
    }

    int findHash(string name)
    {
        unsigned long hash=0;
        for(int i=0;i<name.length();i++)
        {
            hash=name[i]+(hash<<6)+(hash<<16)-hash;
        }
        return hash%bucketSize;
    }

    bool Insert(string name,string type)
    {
        int hash=findHash(name);//need to find hash value
        SymbolInfo *currentobj=*(scopeTable+hash);
        int position=0;
        if(currentobj== nullptr)
        {
            SymbolInfo *obj=new SymbolInfo(name,type);
            currentobj=obj;
            *(scopeTable+hash)=currentobj;
            //cout<<"Inserted in Scope table "<<ID<<" at position "<<hash<<","<<position<<endl;
            return true;
        }
        else if(currentobj->next==nullptr)
        {
            position++;
            if(currentobj->getName()==name)
            {
                //cout<<"This word already exists."<<endl;
                //cout<<"<"<<name<<","<<type<<">"<<" already exists in the current scope table"<<endl;
                //fprintf(logout,"This token already exists in the scope table\n");
                return false;
            }
            SymbolInfo *obj=new SymbolInfo(name,type);
            currentobj->next=obj;
           // cout<<"Inserted in Scope table "<<ID<<" at position "<<hash<<","<<position<<endl;
            return true;
        }
        else{

            while(currentobj->next!=nullptr)
            {
                if(name==currentobj->getName())
                {
                    //cout<<"This word already exists."<<endl;
                    //cout<<"<"<<name<<","<<type<<">"<<" already exists in the current scope table"<<endl;
                   // fprintf(logout,"This token already exists in the scope table\n");
                    return false;
                }
                currentobj=currentobj->next;
                position++;
            }
            position++;
            SymbolInfo *obj=new SymbolInfo(name,type);
            currentobj->next=obj;
            //cout<<"Inserted in Scope table "<<ID<<" at position "<<hash<<","<<position<<endl;
            return true;

        }
    }

    SymbolInfo* Lookup(string name)
    {
        int hash=findHash(name);//need to find hash value
        SymbolInfo *currentobj=*(scopeTable+hash);
        int position=0;
        if(currentobj== nullptr)
        {
            return nullptr;
        }
        while(currentobj!=nullptr)
        {
            if(name==currentobj->getName())
            {
                cout<<"Found in scope table "<<ID<<" at position "<<hash<<","<<position<<endl;
                return currentobj;
            }
            position++;
            currentobj=currentobj->next;
        }
        return nullptr;
    }

    bool Delete(string name)
    {
        int hash=findHash(name);//need to find hash value
        bool found=false;
        SymbolInfo *currentobj=*(scopeTable+hash);
        SymbolInfo *desiredObj;
        while(currentobj!= nullptr)
        {
            if(name==currentobj->getName())
            {
                desiredObj=currentobj;
                found=true;
                break;
            }
            currentobj=currentobj->next;
        }
        if(found)
        {
            currentobj=*(scopeTable+hash);
            while(currentobj->next!=desiredObj && currentobj->next!=nullptr)
            {
                currentobj=currentobj->next;
            }
            if(currentobj->getName()==desiredObj->getName())
            {
                *(scopeTable+hash)= nullptr;
                cout<<"Symbol deleted"<<"yo"<<endl;
                return true;
            }
            currentobj->next=currentobj->next->next;
            cout<<"Symbol deleted";
            delete desiredObj;
            return true;
        } else{
            cout<<"Symbol not found"<<endl;
            return false;
        }
    }

    void Print(FILE *file)
    {
        //cout<<"Scope table "<<ID<<endl;
        fprintf(file,"Scope table #%s\n",ID.c_str());
        for(int i=0;i<bucketSize;i++)
        {
            SymbolInfo *current=*(scopeTable+i);
            if(current!=nullptr)
            {
                //cout<<i<<"-->";
                fprintf(file,"%d--> ",i);
                while(current!=nullptr)
               {
                current->printSymbolInfoObject(file);
               // cout<<" ";
                fprintf(file," ");
                current=current->next;
               }
               // cout<<endl;
                fprintf(file,"\n\n");
            }
            //cout<<i<<"-->";
        }
    }
};

class SymbolTable{
private:
    ScopeTable *currentScopeTable;
    int n;
public:

    SymbolTable(ScopeTable *scopeTable)
    {
        currentScopeTable=scopeTable;
    }

    SymbolTable(int n)
    {
        currentScopeTable=new ScopeTable(n);
        this->n=n;
    }

    ~SymbolTable()
    {
        delete currentScopeTable;
    }

    void EnterScope()
    {
        currentScopeTable->childrenCount=currentScopeTable->childrenCount+1;
        ScopeTable *scopeTable=new ScopeTable(n,currentScopeTable);
        currentScopeTable=scopeTable;
    }

    void ExitScope()
    {
        if(currentScopeTable==nullptr)
        {
            cout<<"No scope to delete"<<endl;
        } else{
            ScopeTable *toBeDeleted=currentScopeTable;
            currentScopeTable=currentScopeTable->parentScope;
            delete toBeDeleted;
        }
    }

    bool Insert(string name,string type)
    {
        if(currentScopeTable==nullptr)
        {
            currentScopeTable=new ScopeTable(n);
            this->n=n;
        }
        return currentScopeTable->Insert(name,type);
    }

    bool Delete(string name)
    {
        return currentScopeTable->Delete(name);
    }

    SymbolInfo* Lookup(string name)
    {
        ScopeTable *current=currentScopeTable;
        while(current->parentScope!=nullptr)
        {
            SymbolInfo *obj=current->Lookup(name);
            if(obj!= nullptr)
            {
                return obj;
            }
            current=current->parentScope;
        }
        SymbolInfo *obj=current->Lookup(name);
        if(obj== nullptr)
        {
            cout<<"Not found"<<endl;
            return nullptr;
        } else{
            return obj;
        }
    }

    /*void PrintCurrentTable()
    {
        currentScopeTable->Print();
    }*/

    void PrintAllTable(FILE *file)
    {
        ScopeTable *current=currentScopeTable;
        while(current->parentScope!=nullptr)
        {
            current->Print(file);
            current=current->parentScope;
        }
        current->Print(file);
    }

};

