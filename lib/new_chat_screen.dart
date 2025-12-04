import 'package:flutter/material.dart';
import 'models/contact.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  void _loadContacts() {
    _allContacts = [
      Contact(
        id: '1',
        name: 'Марія Петренко',
        email: 'maria.p@example.com',
        initials: 'МП',
        avatarColor: Color(0xFFFF5722),
        isOnline: false,
        isSelected: true,
      ),
      Contact(
        id: '2',
        name: 'Іван Шевченко',
        email: 'ivan.sh@example.com',
        initials: 'ІШ',
        avatarColor: Color(0xFF2196F3),
        isOnline: true,
        isSelected: true,
      ),
      Contact(
        id: '3',
        name: 'Тарас Коваленко',
        email: 'taras.k@example.com',
        initials: 'ТК',
        avatarColor: Color(0xFF9C27B0),
        isOnline: false,
        lastSeen: 'був 2 години тому',
        isSelected: false,
      ),
      Contact(
        id: '4',
        name: 'Олена Коваль',
        email: 'olena.k@example.com',
        initials: 'ОК',
        avatarColor: Color(0xFF4CAF50),
        isOnline: false,
        isSelected: true,
      ),
      Contact(
        id: '5',
        name: 'Андрій Мельник',
        email: 'andrii.m@example.com',
        initials: 'АМ',
        avatarColor: Color(0xFFE91E63),
        isOnline: true,
        isSelected: false,
      ),
    ];
    _filteredContacts = _allContacts;
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts.where((contact) {
          return contact.name.toLowerCase().contains(query) ||
              contact.email.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _toggleContactSelection(String contactId) {
    setState(() {
      final index = _allContacts.indexWhere((c) => c.id == contactId);
      if (index != -1) {
        _allContacts[index] = _allContacts[index].copyWith(
          isSelected: !_allContacts[index].isSelected,
        );
      }
      _filterContacts();
    });
  }

  void _removeFromGroup(String contactId) {
    _toggleContactSelection(contactId);
  }

  List<Contact> get _selectedContacts =>
      _allContacts.where((c) => c.isSelected).toList();

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedContacts.length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF5F00EB),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Новий чат',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Приватний'),
              Tab(text: 'Груповий'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPrivateChatTab(),
            _buildGroupChatTab(selectedCount),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateChatTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Пошук за email або ім\'ям...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'КОНТАКТИ',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _filteredContacts.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_search,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 16),
                Text(
                  'Контактів не знайдено',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = _filteredContacts[index];
              return _buildContactItem(contact);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupChatTab(int selectedCount) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Назва групи',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: 'Назва групи',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Додати учасників...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'УЧАСНИКИ ($selectedCount)',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _selectedContacts.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_add,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 16),
                Text(
                  'Оберіть учасників групи',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _selectedContacts.length,
            itemBuilder: (context, index) {
              final contact = _selectedContacts[index];
              return Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: contact.avatarColor,
                    radius: 24,
                    child: Text(
                      contact.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => _removeFromGroup(contact.id),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.remove,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedCount >= 2
                      ? () {
                    // Логіка створення групи
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Створення групи "${_groupNameController.text.isEmpty ? "Нова група" : _groupNameController.text}" з $selectedCount учасниками'),
                        backgroundColor: Color(0xFF5F00EB),
                      ),
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F00EB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Створити групу',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                selectedCount < 2
                    ? 'Оберіть мінімум 2 учасники'
                    : 'Максимум 20 учасників',
                style: TextStyle(
                  color: selectedCount < 2
                      ? Colors.red.shade400
                      : Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(Contact contact) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: contact.avatarColor,
              radius: 24,
              child: Text(
                contact.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (contact.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          contact.lastSeen ?? contact.email,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        onTap: () {
          // Перехід до приватного чату
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Відкрити чат з ${contact.name}'),
              duration: Duration(seconds: 1),
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}